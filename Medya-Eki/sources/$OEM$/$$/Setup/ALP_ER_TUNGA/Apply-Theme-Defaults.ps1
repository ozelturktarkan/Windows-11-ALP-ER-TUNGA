$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Theme.json') -Raw | ConvertFrom-Json
if ($config.Profile -notmatch '^[A-Z_]+$') { throw 'Invalid theme profile.' }
if ($PSScriptRoot -ine (Join-Path $env:SystemRoot ('Setup\' + $config.Profile))) { throw 'Target Windows Setup folder required.' }
if ([Security.Principal.WindowsIdentity]::GetCurrent().User.Value -ne 'S-1-5-18') { throw 'Windows Setup SYSTEM context required.' }
$os = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
if ($os.EditionID -ne $config.Edition -or $os.CurrentBuildNumber -ne $config.Build) { throw 'Unexpected Windows image.' }
$wallpaper = Join-Path $env:SystemRoot $config.Wallpaper
$cursor = Join-Path $env:SystemRoot $config.Cursor
foreach ($file in @($wallpaper, $cursor, (Join-Path $PSScriptRoot 'Apply-UserTheme.ps1'))) {
    if (-not (Test-Path -LiteralPath $file)) { throw ('Missing theme file: ' + $file) }
}
if ((Get-FileHash -LiteralPath $wallpaper -Algorithm SHA256).Hash -ine $config.WallpaperSHA256) { throw 'Wallpaper checksum mismatch.' }
if ((Get-FileHash -LiteralPath $cursor -Algorithm SHA256).Hash -ine $config.CursorSHA256) { throw 'Cursor checksum mismatch.' }
function Put($Key, $Name, $Value) {
    if (-not (Test-Path -LiteralPath $Key)) { New-Item -Path $Key -Force | Out-Null }
    New-ItemProperty -LiteralPath $Key -Name $Name -Value $Value -PropertyType String -Force | Out-Null
}
$hiveName = 'HAKANLAR_Theme_Default'
$loaded = $false
Start-Transcript -Path (Join-Path $PSScriptRoot 'Theme-Setup.log') -Append | Out-Null
try {
    if (Test-Path ('Registry::HKEY_USERS\' + $hiveName)) { throw 'Theme hive name already in use.' }
    $defaultPath = [Environment]::ExpandEnvironmentVariables((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList').Default)
    & "$env:SystemRoot\System32\reg.exe" load ('HKU\' + $hiveName) (Join-Path $defaultPath 'NTUSER.DAT')
    if ($LASTEXITCODE -ne 0) { throw 'Default user hive could not be loaded.' }
    $loaded = $true
    $root = 'Registry::HKEY_USERS\' + $hiveName
    Put ($root + '\Control Panel\Desktop') 'Wallpaper' $wallpaper
    Put ($root + '\Control Panel\Desktop') 'WallpaperStyle' '2'
    Put ($root + '\Control Panel\Desktop') 'TileWallpaper' '0'
    Put ($root + '\Control Panel\Cursors') 'Arrow' $cursor
    Put ($root + '\Software\Microsoft\Windows\CurrentVersion\Themes') 'CurrentTheme' (Join-Path $env:SystemRoot ('Resources\Themes\' + $config.Profile + '.theme'))
    $command = '"' + $env:SystemRoot + '\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $PSScriptRoot + '\Apply-UserTheme.ps1"'
    Put ($root + '\Software\Microsoft\Windows\CurrentVersion\RunOnce') ('!HAKANLAR-' + $config.Profile + '-Theme') $command
    [GC]::Collect(); [GC]::WaitForPendingFinalizers()
    & "$env:SystemRoot\System32\reg.exe" unload ('HKU\' + $hiveName)
    if ($LASTEXITCODE -ne 0) { throw 'Default user hive could not be unloaded.' }
    $loaded = $false
    Write-Output 'Default wallpaper and cursor installed. No service, network or security settings changed by this theme script.'
} finally {
    if ($loaded) { [GC]::Collect(); [GC]::WaitForPendingFinalizers(); & "$env:SystemRoot\System32\reg.exe" unload ('HKU\' + $hiveName) }
    Stop-Transcript | Out-Null
}
