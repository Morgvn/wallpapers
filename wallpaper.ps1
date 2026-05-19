# ==========================================
# CORPORATE WALLPAPER + LOCKSCREEN
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
Invoke-WebRequest $WallpaperURL -OutFile $WallpaperDestination
Invoke-WebRequest $LockscreenURL -OutFile $LockScreenDestination

# Registro Windows
$RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

# Crear clave si no existe
if (!(Test-Path $RegKeyPath)) {
    New-Item -Path $RegKeyPath -Force | Out-Null
}

# Wallpaper
New-ItemProperty `
-Path $RegKeyPath `
-Name "DesktopImageStatus" `
-Value 1 `
-PropertyType DWORD `
-Force | Out-Null

New-ItemProperty `
-Path $RegKeyPath `
-Name "DesktopImagePath" `
-Value $WallpaperDestination `
-PropertyType String `
-Force | Out-Null

New-ItemProperty `
-Path $RegKeyPath `
-Name "DesktopImageUrl" `
-Value $WallpaperDestination `
-PropertyType String `
-Force | Out-Null

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

# Actualizar Windows
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Reiniciar explorer
Stop-Process -Name explorer -Force

# Limpiar errores
$error.clear()