param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Text,

    [string]$Output = (Join-Path $env:USERPROFILE "Downloads\baisound-voice.wav"),

    [string]$SettingsFile = (Join-Path $PSScriptRoot "BAISOUND-API-SETTINGS.local.ps1"),

    [switch]$SkipModelSwitch,

    [switch]$Play
)

$ErrorActionPreference = "Stop"

function Get-RequiredSetting {
    param([Parameter(Mandatory=$true)][string]$Name)

    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Required setting is empty: $Name"
    }
    return $value
}

function Resolve-RequiredFile {
    param(
        [Parameter(Mandatory=$true)][string]$Value,
        [Parameter(Mandatory=$true)][string]$Label
    )

    if (-not (Test-Path -LiteralPath $Value -PathType Leaf)) {
        throw "$Label does not exist: $Value"
    }
    return (Resolve-Path -LiteralPath $Value).Path
}

if (-not (Test-Path -LiteralPath $SettingsFile -PathType Leaf)) {
    throw "Settings file was not found. Copy BAISOUND-API-SETTINGS.example.ps1 to BAISOUND-API-SETTINGS.local.ps1 first."
}

. (Resolve-Path -LiteralPath $SettingsFile).Path

$hostName = if ($env:BAISOUND_API_HOST) { $env:BAISOUND_API_HOST } else { "127.0.0.1" }
if ($hostName -notin @("127.0.0.1", "localhost", "::1")) {
    throw "This public example only permits a loopback host. Do not expose the upstream API directly to a network."
}

$port = if ($env:BAISOUND_API_PORT) { [int]::Parse($env:BAISOUND_API_PORT) } else { 9880 }
$baseUrl = "http://${hostName}:$port"
$modelRootValue = Get-RequiredSetting "BAISOUND_VOICE_MODEL_ROOT"
if (-not (Test-Path -LiteralPath $modelRootValue -PathType Container)) {
    throw "BAISOUND model root does not exist: $modelRootValue"
}
$modelRoot = (Resolve-Path -LiteralPath $modelRootValue).Path
$gptModel = Resolve-RequiredFile (Join-Path $modelRoot "models\stable\v2\baisound-voice-v2-gpt.ckpt") "BAISOUND GPT model"
$sovitsModel = Resolve-RequiredFile (Join-Path $modelRoot "models\stable\v2\baisound-voice-v2-sovits.pth") "BAISOUND SoVITS model"
$reference = Resolve-RequiredFile (Get-RequiredSetting "BAISOUND_REFERENCE_WAV") "Reference WAV"
$referenceText = Get-RequiredSetting "BAISOUND_REFERENCE_TEXT"

if (-not $SkipModelSwitch) {
    foreach ($entry in @(
        @{ Endpoint = "set_gpt_weights"; Path = $gptModel },
        @{ Endpoint = "set_sovits_weights"; Path = $sovitsModel }
    )) {
        $encodedPath = [Uri]::EscapeDataString($entry.Path)
        $uri = "${baseUrl}/$($entry.Endpoint)?weights_path=$encodedPath"
        Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 120 | Out-Null
    }
}

$outputParent = Split-Path -Parent $Output
if ($outputParent -and -not (Test-Path -LiteralPath $outputParent)) {
    New-Item -ItemType Directory -Path $outputParent -Force | Out-Null
}

$payload = @{
    text = $Text
    text_lang = "ja"
    ref_audio_path = $reference
    prompt_lang = "ja"
    prompt_text = $referenceText
    text_split_method = "cut5"
    batch_size = 1
    media_type = "wav"
    streaming_mode = $false
}

$json = $payload | ConvertTo-Json -Compress
$body = [Text.Encoding]::UTF8.GetBytes($json)

Invoke-WebRequest `
    -Uri "${baseUrl}/tts" `
    -Method Post `
    -ContentType "application/json; charset=utf-8" `
    -Body $body `
    -OutFile $Output `
    -TimeoutSec 300 `
    -UseBasicParsing

if (-not (Test-Path -LiteralPath $Output -PathType Leaf)) {
    throw "Output WAV was not created."
}

$bytes = [IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Output).Path)
if ($bytes.Length -lt 44) {
    throw "Output is too small to be a WAV file."
}

$riff = [Text.Encoding]::ASCII.GetString($bytes, 0, 4)
$wave = [Text.Encoding]::ASCII.GetString($bytes, 8, 4)
if ($riff -ne "RIFF" -or $wave -ne "WAVE") {
    throw "The API response is not a RIFF/WAVE file."
}

$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $Output).Hash.ToLowerInvariant()
Write-Host "BAISOUND TTS: SUCCESS" -ForegroundColor Green
Write-Host "WAV    : $((Resolve-Path -LiteralPath $Output).Path)"
Write-Host "Bytes  : $($bytes.Length)"
Write-Host "SHA-256: $hash"

if ($Play) {
    Start-Process -FilePath (Resolve-Path -LiteralPath $Output).Path
}
