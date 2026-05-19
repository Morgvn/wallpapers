# ==========================================
# WALLPAPER + LOCKSCREEN
# MÉTODO QUE SÍ FUNCIONA
# ==========================================

# URLs
$WallpaperURL = "https://raw.githubusercontent.com/Morgvn/wallpapers/main/wallpaper.jpg"
$LockscreenUrl = "https://raw.githubusercontent.com/Morgvn/wallpapers/main/lockscreen.jpeg"

# Carpeta destino
$ImageDestinationFolder = "C:\Users"

# Archivos destino
$WallpaperDestinationFile = "$ImageDestinationFolder\wallpaper.jpg"
$LockScreenDestinationFile = "$ImageDestinationFolder\lockscreen.jpeg"

# Crear carpeta
mkdir $ImageDestinationFolder -ErrorAction SilentlyContinue

# Descargar imágenes
Start-BitsTransfer -Source $WallpaperURL -Destination $WallpaperDestinationFile
Start-BitsTransfer -Source $LockscreenUrl -Destination $LockScreenDestinationFile

# ==========================================
# REGISTRO PERSONALIZATION CSP
# ==========================================

$RegKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'

$DesktopPath = "DesktopImagePath"
$DesktopStatus = "DesktopImageStatus"
$DesktopUrl = "DesktopImageUrl"

$LockScreenPath = "LockScreenImagePath"
$LockScreenStatus = "LockScreenImageStatus"
$LockScreenUrl = "LockScreenImageUrl"

$StatusValue = 1

$DesktopImageValue = $WallpaperDestinationFile
$LockScreenImageValue = $LockScreenDestinationFile

# Crear clave si no existe
if (!(Test-Path $RegKeyPath)) {

    New-Item -Path $RegKeyPath -Force | Out-Null

}

# Wallpaper
New-ItemProperty `
-Path $RegKeyPath `
-Name $DesktopStatus `
-Value $StatusValue `
-PropertyType DWORD `
-Force | Out-Null

New-ItemProperty `
-Path $RegKeyPath `
-Name $DesktopPath `
-Value $DesktopImageValue `
-PropertyType STRING `
-Force | Out-Null

New-ItemProperty `
-Path $RegKeyPath `
-Name $DesktopUrl `
-Value $DesktopImageValue `
-PropertyType STRING `
-Force | Out-Null

# Lockscreen
New-ItemProperty `
-Path $RegKeyPath `
-Name $LockScreenStatus `
-Value $StatusValue `
-PropertyType DWORD `
-Force | Out-Null

New-ItemProperty `
-Path $RegKeyPath `
-Name $LockScreenPath `
-Value $LockScreenImageValue `
-PropertyType STRING `
-Force | Out-Null

New-ItemProperty `
-Path $RegKeyPath `
-Name $LockScreenUrl `
-Value $LockScreenImageValue `
-PropertyType STRING `
-Force | Out-Null

# Refrescar políticas
gpupdate /force

# Refrescar Windows
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Limpiar errores
$error.clear()