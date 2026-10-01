param([Parameter(Mandatory=$true)][string]$IsoPath)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$release = Get-Content -LiteralPath (Join-Path $repo 'SURUM.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $release.hashes.sha256) { throw 'Bu profil icin henuz ISO hash kaydi yok.' }
$file = Get-Item -LiteralPath $IsoPath
if ($file.Length -ne $release.iso_bytes) { throw 'ISO boyutu eslesmiyor.' }
if ((Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash -ine $release.hashes.sha256) { throw 'ISO SHA-256 eslesmiyor.' }
Write-Output 'ISO boyutu ve SHA-256 yayin kaydiyla eslesti.'
