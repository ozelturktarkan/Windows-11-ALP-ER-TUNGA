$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$manifest = Get-Content -LiteralPath (Join-Path $repo 'DOSYALAR-SHA256.json') -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($entry in $manifest.PSObject.Properties) {
    $file = Join-Path $repo $entry.Name
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Eksik: $($entry.Name)" }
    if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -ine $entry.Value) { throw "Hash farkli: $($entry.Name)" }
}
Write-Output 'Kaynak dosyalari SHA-256 manifestiyle eslesti.'
