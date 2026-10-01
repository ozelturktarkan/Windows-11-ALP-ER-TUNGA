$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Theme.json') -Raw | ConvertFrom-Json
if ($config.Profile -notmatch '^[A-Z_]+$') { throw 'Invalid theme profile.' }
if ($PSScriptRoot -ine (Join-Path $env:SystemRoot ('Setup\' + $config.Profile))) { throw 'Target Windows Setup folder required.' }
if ([Security.Principal.WindowsIdentity]::GetCurrent().User.Value -eq 'S-1-5-18') { throw 'Interactive user context required.' }
$marker = 'HKCU:\Software\HAKANLAR\' + $config.Profile
$previous = Get-ItemProperty -LiteralPath $marker -ErrorAction SilentlyContinue
if ($previous -and $previous.PSObject.Properties['ThemeRevision'] -and $previous.ThemeRevision -eq 1) { exit 0 }
$wallpaper = Join-Path $env:SystemRoot $config.Wallpaper
$cursor = Join-Path $env:SystemRoot $config.Cursor
if ((Get-FileHash -LiteralPath $wallpaper -Algorithm SHA256).Hash -ine $config.WallpaperSHA256) { throw 'Wallpaper checksum mismatch.' }
if ((Get-FileHash -LiteralPath $cursor -Algorithm SHA256).Hash -ine $config.CursorSHA256) { throw 'Cursor checksum mismatch.' }
$logDir = Join-Path $env:LOCALAPPDATA ('HAKANLAR\' + $config.Profile)
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
Start-Transcript -Path (Join-Path $logDir 'Theme-FirstLogon.log') -Append | Out-Null
function Put($Key, $Name, $Value) {
    if (-not (Test-Path -LiteralPath $Key)) { New-Item -Path $Key -Force | Out-Null }
    New-ItemProperty -LiteralPath $Key -Name $Name -Value $Value -PropertyType String -Force | Out-Null
}
try {
    Put 'HKCU:\Control Panel\Desktop' 'Wallpaper' $wallpaper
    Put 'HKCU:\Control Panel\Desktop' 'WallpaperStyle' '2'
    Put 'HKCU:\Control Panel\Desktop' 'TileWallpaper' '0'
    Put 'HKCU:\Control Panel\Cursors' 'Arrow' $cursor
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class HakanlarTheme {
 [DllImport("user32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
 [return:MarshalAs(UnmanagedType.Bool)]
 public static extern bool SystemParametersInfo(uint action, uint param, string value, uint flags);
 [DllImport("user32.dll", EntryPoint="SystemParametersInfoW", SetLastError=true)]
 [return:MarshalAs(UnmanagedType.Bool)]
 private static extern bool SpiPointer(uint action, uint param, IntPtr value, uint flags);
 public static bool ReloadCursors() { return SpiPointer(87, 0, IntPtr.Zero, 0); }
}
'@
    if (-not [HakanlarTheme]::SystemParametersInfo(20, 0, $wallpaper, 3)) { throw 'Wallpaper could not be applied.' }
    if (-not [HakanlarTheme]::ReloadCursors()) { throw 'Cursor could not be applied.' }
    if (-not (Test-Path -LiteralPath $marker)) { New-Item -Path $marker -Force | Out-Null }
    New-ItemProperty -LiteralPath $marker -Name ThemeRevision -PropertyType DWord -Value 1 -Force | Out-Null
    Write-Output 'Theme applied once. Future user customization is preserved.'
} finally { Stop-Transcript | Out-Null }
