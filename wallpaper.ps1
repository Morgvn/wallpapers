# ==========================================
# CORPORATE WALLPAPER + LOCKSCREEN
# FINAL VERSION
# ==========================================

# URLs
$WallpaperURL = "https://raw.githubusercontent.com/Morgvn/wallpapers/main/wallpaper.jpg"
$LockscreenURL = "https://raw.githubusercontent.com/Morgvn/wallpapers/main/lockscreen.jpeg"

# Carpeta destino
$DestinationFolder = "C:\ProgramData\CorporateWallpaper"

# Crear carpeta
New-Item -ItemType Directory -Path $DestinationFolder -Force | Out-Null

# Destinos
$WallpaperDestination = "$DestinationFolder\wallpaper.jpg"
$LockScreenDestination = "$DestinationFolder\lockscreen.jpeg"

# Descargar imágenes
Start-BitsTransfer -Source $WallpaperURL -Destination $WallpaperDestination
Start-BitsTransfer -Source $LockscreenURL -Destination $LockScreenDestination

# ==========================================
# LOCKSCREEN GLOBAL
# ==========================================

$RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

if (!(Test-Path $RegKeyPath)) {
    New-Item -Path $RegKeyPath -Force | Out-Null
}

New-ItemProperty -Path $RegKeyPath -Name "LockScreenImageStatus" -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name "LockScreenImagePath" -Value $LockScreenDestination -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name "LockScreenImageUrl" -Value $LockScreenDestination -PropertyType String -Force | Out-Null

# ==========================================
# WALLPAPER TODOS LOS USUARIOS
# ==========================================

# Obtener perfiles de usuario reales
$Profiles = Get-ChildItem "HKU:\" | Where-Object {
    $_.Name -match "S-1-5-21"
}

foreach ($Profile in $Profiles) {

    $DesktopKey = "$($Profile.Name)\Control Panel\Desktop"

    try {

        Set-ItemProperty `
        -Path "Registry::$DesktopKey" `
        -Name Wallpaper `
        -Value $WallpaperDestination `
        -Force

        Set-ItemProperty `
        -Path "Registry::$DesktopKey" `
        -Name WallpaperStyle `
        -Value "10" `
        -Force

        Set-ItemProperty `
        -Path "Registry::$DesktopKey" `
        -Name TileWallpaper `
        -Value "0" `
        -Force

    } catch {}

}

# ==========================================
# ACTUALIZAR WALLPAPER ACTUAL
# ==========================================

Add-Type @"
using System.Runtime.InteropServices;

public class Wallpaper
{
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SystemParametersInfo
    (
        int uAction,
        int uParam,
        string lpvParam,
        int fuWinIni
    );
}
"@

# Aplicar inmediatamente
[Wallpaper]::SystemParametersInfo(20, 0, $WallpaperDestination, 3)

# Refrescar
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Reiniciar explorer
Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process explorer.exe

Write-Output "Wallpaper y Lockscreen aplicados correctamente"