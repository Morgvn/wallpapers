# ==========================================
# CORPORATE WALLPAPER + LOCKSCREEN
# Compatible con usuarios locales y admin
# Sin reinicio
# ==========================================

# URLs de imágenes
$WallpaperURL = "https://raw.githubusercontent.com/Morgvn/wallpapers/main/wallpaper.jpg"
$LockscreenURL = "https://raw.githubusercontent.com/Morgvn/wallpapers/main/lockscreen.jpeg"

# Carpeta destino
$DestinationFolder = "C:\ProgramData\CorporateWallpaper"

# Crear carpeta si no existe
New-Item -ItemType Directory -Path $DestinationFolder -Force | Out-Null

# Archivos destino
$WallpaperDestination = "$DestinationFolder\wallpaper.jpg"
$LockScreenDestination = "$DestinationFolder\lockscreen.jpeg"

# Descargar imágenes
Start-BitsTransfer -Source $WallpaperURL -Destination $WallpaperDestination
Start-BitsTransfer -Source $LockscreenURL -Destination $LockScreenDestination

# ==========================================
# LOCKSCREEN (GLOBAL)
# ==========================================

$RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

if (!(Test-Path $RegKeyPath)) {
    New-Item -Path $RegKeyPath -Force | Out-Null
}

# Lockscreen
New-ItemProperty `
-Path $RegKeyPath `
-Name "LockScreenImageStatus" `
-Value 1 `
-PropertyType DWORD `
-Force | Out-Null

New-ItemProperty `
-Path $RegKeyPath `
-Name "LockScreenImagePath" `
-Value $LockScreenDestination `
-PropertyType String `
-Force | Out-Null

New-ItemProperty `
-Path $RegKeyPath `
-Name "LockScreenImageUrl" `
-Value $LockScreenDestination `
-PropertyType String `
-Force | Out-Null

# ==========================================
# WALLPAPER USUARIO ACTUAL
# ==========================================

# Registro wallpaper
Set-ItemProperty `
-Path "HKCU:\Control Panel\Desktop" `
-Name Wallpaper `
-Value $WallpaperDestination

Set-ItemProperty `
-Path "HKCU:\Control Panel\Desktop" `
-Name WallpaperStyle `
-Value 10

Set-ItemProperty `
-Path "HKCU:\Control Panel\Desktop" `
-Name TileWallpaper `
-Value 0

# API Windows para refrescar instantáneamente
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

# Aplicar wallpaper inmediatamente
[Wallpaper]::SystemParametersInfo(20, 0, $WallpaperDestination, 3)

# Refrescar políticas
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Reiniciar explorer suavemente
Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process explorer.exe

# Limpiar errores
$error.clear()

Write-Output "Wallpaper y Lockscreen aplicados correctamente"