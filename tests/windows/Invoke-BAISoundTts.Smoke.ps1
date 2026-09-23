$ErrorActionPreference = "Stop"

function Assert-True {
    param(
        [Parameter(Mandatory=$true)][bool]$Condition,
        [Parameter(Mandatory=$true)][string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function ConvertTo-SingleQuotedPowerShellLiteral {
    param([Parameter(Mandatory=$true)][string]$Value)
    return "'" + $Value.Replace("'", "''") + "'"
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$client = Join-Path $repoRoot "examples\windows\Invoke-BAISoundTts.ps1"
$mockServer = Join-Path $repoRoot "tests\windows\mock_gptsovits_api.py"
$python = Get-Command python -ErrorAction Stop

$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
$listener.Start()
$port = ([Net.IPEndPoint]$listener.LocalEndpoint).Port
$listener.Stop()

$testRoot = Join-Path ([IO.Path]::GetTempPath()) ("baisound-windows-smoke-" + [Guid]::NewGuid().ToString("N"))
$modelRoot = Join-Path $testRoot "model repo"
$stableRoot = Join-Path $modelRoot "models\stable\v2"
$reference = Join-Path $testRoot "reference.wav"
$settings = Join-Path $testRoot "settings.ps1"
$output = Join-Path $testRoot "output\voice.wav"
$receipt = Join-Path $testRoot "receipt.json"
$serverOut = Join-Path $testRoot "server.stdout.log"
$serverErr = Join-Path $testRoot "server.stderr.log"
$serverProcess = $null

try {
    New-Item -ItemType Directory -Path $stableRoot -Force | Out-Null
    [IO.File]::WriteAllBytes((Join-Path $stableRoot "baisound-voice-v2-gpt.ckpt"), [byte[]](1, 2, 3))
    [IO.File]::WriteAllBytes((Join-Path $stableRoot "baisound-voice-v2-sovits.pth"), [byte[]](4, 5, 6))
    [IO.File]::WriteAllBytes($reference, [byte[]](7, 8, 9))

    $settingsContent = @(
        "`$env:BAISOUND_VOICE_MODEL_ROOT = $(ConvertTo-SingleQuotedPowerShellLiteral $modelRoot)"
        "`$env:BAISOUND_REFERENCE_WAV = $(ConvertTo-SingleQuotedPowerShellLiteral $reference)"
        "`$env:BAISOUND_REFERENCE_TEXT = 'これはテスト用の参照文です。'"
        "`$env:BAISOUND_API_HOST = '127.0.0.1'"
        "`$env:BAISOUND_API_PORT = '$port'"
    ) -join [Environment]::NewLine
    [IO.File]::WriteAllText($settings, $settingsContent, [Text.UTF8Encoding]::new($false))

    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $python.Source
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.ArgumentList.Add($mockServer)
    $startInfo.ArgumentList.Add("--host")
    $startInfo.ArgumentList.Add("127.0.0.1")
    $startInfo.ArgumentList.Add("--port")
    $startInfo.ArgumentList.Add([string]$port)
    $startInfo.ArgumentList.Add("--receipt")
    $startInfo.ArgumentList.Add($receipt)

    $serverProcess = [Diagnostics.Process]::new()
    $serverProcess.StartInfo = $startInfo
    Assert-True $serverProcess.Start() "Mock API failed to start."

    $ready = $false
    foreach ($attempt in 1..50) {
        if ($serverProcess.HasExited) {
            throw "Mock API exited before becoming ready: $($serverProcess.StandardError.ReadToEnd())"
        }
        try {
            Invoke-RestMethod -Uri "http://127.0.0.1:$port/health" -TimeoutSec 1 | Out-Null
            $ready = $true
            break
        }
        catch {
            Start-Sleep -Milliseconds 100
        }
    }
    Assert-True $ready "Mock API did not become ready."

    $text = "Windowsクライアントの自動テストです。"
    & $client -Text $text -Output $output -SettingsFile $settings

    Assert-True (Test-Path -LiteralPath $output -PathType Leaf) "The client did not create a WAV file."
    $wav = [IO.File]::ReadAllBytes($output)
    Assert-True ($wav.Length -gt 44) "The generated WAV is too small."
    Assert-True ([Text.Encoding]::ASCII.GetString($wav, 0, 4) -eq "RIFF") "RIFF header is missing."
    Assert-True ([Text.Encoding]::ASCII.GetString($wav, 8, 4) -eq "WAVE") "WAVE header is missing."

    $record = Get-Content -LiteralPath $receipt -Raw | ConvertFrom-Json
    $gptEvent = @($record.events | Where-Object { $_.path -eq "/set_gpt_weights" })
    $sovitsEvent = @($record.events | Where-Object { $_.path -eq "/set_sovits_weights" })
    $ttsEvent = @($record.events | Where-Object { $_.path -eq "/tts" })

    Assert-True ($gptEvent.Count -eq 1) "GPT model switch request was not captured exactly once."
    Assert-True ($sovitsEvent.Count -eq 1) "SoVITS model switch request was not captured exactly once."
    Assert-True ($ttsEvent.Count -eq 1) "TTS request was not captured exactly once."
    Assert-True ($gptEvent[0].weights_path -eq (Join-Path $stableRoot "baisound-voice-v2-gpt.ckpt")) "GPT model path mismatch."
    Assert-True ($sovitsEvent[0].weights_path -eq (Join-Path $stableRoot "baisound-voice-v2-sovits.pth")) "SoVITS model path mismatch."
    Assert-True ($ttsEvent[0].payload.text -eq $text) "TTS text mismatch."
    Assert-True ($ttsEvent[0].payload.text_lang -eq "ja") "TTS language mismatch."
    Assert-True ($ttsEvent[0].payload.ref_audio_path -eq $reference) "Reference audio path mismatch."
    Assert-True ($ttsEvent[0].payload.prompt_text -eq "これはテスト用の参照文です。") "Reference text mismatch."
    Assert-True ($ttsEvent[0].payload.media_type -eq "wav") "Media type mismatch."
    Assert-True ($ttsEvent[0].payload.streaming_mode -eq $false) "Streaming mode mismatch."

    Write-Host "Windows API client smoke test: PASS" -ForegroundColor Green
}
finally {
    if ($serverProcess -and -not $serverProcess.HasExited) {
        $serverProcess.Kill($true)
        $serverProcess.WaitForExit()
    }

    if ($serverProcess) {
        [IO.File]::WriteAllText($serverOut, $serverProcess.StandardOutput.ReadToEnd())
        [IO.File]::WriteAllText($serverErr, $serverProcess.StandardError.ReadToEnd())
    }

    $resolvedTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $resolvedTestRoot = [IO.Path]::GetFullPath($testRoot)
    if ($resolvedTestRoot.StartsWith($resolvedTemp, [StringComparison]::OrdinalIgnoreCase) -and
        [IO.Path]::GetFileName($resolvedTestRoot).StartsWith("baisound-windows-smoke-", [StringComparison]::Ordinal)) {
        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
