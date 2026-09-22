param(
    [Parameter(Mandatory = $true)]
    [string]$Destination,

    [ValidateSet('stable', 'signature-preview')]
    [string]$Profile = 'stable'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$profilePath = Join-Path $root "profiles\$Profile.json"
$profileData = Get-Content -LiteralPath $profilePath -Raw | ConvertFrom-Json

New-Item -ItemType Directory -Force -Path $Destination | Out-Null
foreach ($property in $profileData.models.PSObject.Properties) {
    $model = $property.Value
    $source = Join-Path $root ($model.path -replace '/', '\')
    $actual = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $model.sha256) {
        throw "SHA-256 mismatch: $($model.path)"
    }
    $target = Join-Path $Destination (Split-Path -Leaf $source)
    Copy-Item -LiteralPath $source -Destination $target -Force
    Write-Output "INSTALLED: $target"
}
