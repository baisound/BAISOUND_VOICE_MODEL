param(
    [string]$SettingsFile = (Join-Path $PSScriptRoot "BAISOUND-API-SETTINGS.local.ps1")
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

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory=$true)][string]$Value,
        [Parameter(Mandatory=$true)][string]$Label,
        [ValidateSet("Leaf", "Container")][string]$PathType
    )

    if (-not (Test-Path -LiteralPath $Value -PathType $PathType)) {
        throw "$Label does not exist: $Value"
    }
    return (Resolve-Path -LiteralPath $Value).Path
}

function Resolve-PythonExecutable {
    param([Parameter(Mandatory=$true)][string]$Value)

    if (Test-Path -LiteralPath $Value -PathType Leaf) {
        return (Resolve-Path -LiteralPath $Value).Path
    }

    $command = Get-Command $Value -ErrorAction SilentlyContinue
    if (-not $command) {
        throw "Python executable was not found: $Value"
    }
    return $command.Source
}

function ConvertTo-YamlPath {
    param([Parameter(Mandatory=$true)][string]$Value)
    return $Value.Replace("\", "/").Replace('"', '\"')
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
$device = if ($env:BAISOUND_DEVICE) { $env:BAISOUND_DEVICE } else { "cuda" }
$isHalf = if ($env:BAISOUND_IS_HALF) { $env:BAISOUND_IS_HALF.ToLowerInvariant() } else { "true" }
if ($isHalf -notin @("true", "false")) {
    throw "BAISOUND_IS_HALF must be true or false."
}

$gptRoot = Resolve-ExistingPath (Get-RequiredSetting "BAISOUND_GPTSOVITS_ROOT") "GPT-SoVITS root" "Container"
$modelRoot = Resolve-ExistingPath (Get-RequiredSetting "BAISOUND_VOICE_MODEL_ROOT") "BAISOUND model root" "Container"
$python = Resolve-PythonExecutable (Get-RequiredSetting "BAISOUND_GPTSOVITS_PYTHON")

$apiScript = Resolve-ExistingPath (Join-Path $gptRoot "api_v2.py") "GPT-SoVITS api_v2.py" "Leaf"
$gptModel = Resolve-ExistingPath (Join-Path $modelRoot "models\stable\v2\baisound-voice-v2-gpt.ckpt") "BAISOUND GPT model" "Leaf"
$sovitsModel = Resolve-ExistingPath (Join-Path $modelRoot "models\stable\v2\baisound-voice-v2-sovits.pth") "BAISOUND SoVITS model" "Leaf"
$bert = Resolve-ExistingPath (Join-Path $gptRoot "GPT_SoVITS\pretrained_models\chinese-roberta-wwm-ext-large") "BERT dependency" "Container"
$hubert = Resolve-ExistingPath (Join-Path $gptRoot "GPT_SoVITS\pretrained_models\chinese-hubert-base") "CNHuBERT dependency" "Container"

$configDirectory = Join-Path ([IO.Path]::GetTempPath()) "baisound-voice-model"
[IO.Directory]::CreateDirectory($configDirectory) | Out-Null
$configPath = Join-Path $configDirectory "tts_infer.baisound-v2pro.yaml"

$yaml = [string[]]@(
    "custom:"
    "  bert_base_path: `"$(ConvertTo-YamlPath $bert)`""
    "  cnhuhbert_base_path: `"$(ConvertTo-YamlPath $hubert)`""
    "  device: $device"
    "  is_half: $isHalf"
    "  t2s_weights_path: `"$(ConvertTo-YamlPath $gptModel)`""
    "  version: v2Pro"
    "  vits_weights_path: `"$(ConvertTo-YamlPath $sovitsModel)`""
)

$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllLines($configPath, $yaml, $utf8WithoutBom)

Write-Host "BAISOUND Voice Model API"
Write-Host "Host   : $hostName"
Write-Host "Port   : $port"
Write-Host "Engine : GPT-SoVITS v2Pro"
Write-Host "Config : $configPath"
Write-Host "Stop   : Ctrl+C"

Push-Location $gptRoot
try {
    & $python $apiScript -a $hostName -p $port -c $configPath
    if ($LASTEXITCODE -ne 0) {
        throw "GPT-SoVITS API exited with code $LASTEXITCODE"
    }
}
finally {
    Pop-Location
}
