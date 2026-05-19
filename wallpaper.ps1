# ==========================================
# CORPORATE WALLPAPER + LOCKSCREEN
# MÉTODO CORPORATIVO REAL
# ==========================================

# URLs
$WallpaperURL = "https://raw.githubusercontent.com/Morgvn/wallpapers/main/wallpaper.jpg"
$LockscreenURL = "https://raw.githubusercontent.com/Morgvn/wallpapers/main/lockscreen.jpeg"

# Carpeta
$Folder = "C:\ProgramData\CorporateWallpaper"

# Crear carpeta
New-Item -ItemType Directory -Path $Folder -Force | Out-Null

# Archivos
$Wallpaper = "$Folder\wallpaper.jpg"
$Lockscreen = "$Folder\lockscreen.jpeg"

# Descargar imágenes
Start-BitsTransfer -Source $WallpaperURL -Destination $Wallpaper
Start-BitsTransfer -Source $LockscreenURL -Destination $Lockscreen

# ==========================================
# LOCKSCREEN GLOBAL
# ==========================================

$LockReg = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

if (!(Test-Path $LockReg)) {
    New-Item -Path $LockReg -Force | Out-Null
}

Set-ItemProperty -Path $LockReg -Name LockScreenImagePath -Value $Lockscreen
Set-ItemProperty -Path $LockReg -Name LockScreenImageUrl -Value $Lockscreen
Set-ItemProperty -Path $LockReg -Name LockScreenImageStatus -Value 1

# ==========================================
# WALLPAPER TODOS LOS USUARIOS
# ==========================================

$Profiles = Get-ChildItem "HKU:" | Where-Object {
    $_.Name -match "S-1-5-21"
}

foreach ($User in $Profiles) {

    $Desk = "Registry::$($User.Name)\Control Panel\Desktop"

    try {

        Set-ItemProperty -Path $Desk -Name Wallpaper -Value $Wallpaper
        Set-ItemProperty -Path $Desk -Name WallpaperStyle -Value 10
        Set-ItemProperty -Path $Desk -Name TileWallpaper -Value 0

    } catch {}

}

# Usuario actual
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $Wallpaper
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value 10
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value 0

# Política corporativa
$PolicyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"

if (!(Test-Path $PolicyPath)) {
    New-Item -Path $PolicyPath -Force | Out-Null
}

Set-ItemProperty -Path $PolicyPath -Name Wallpaper -Value $Wallpaper

# Refrescar wallpaper
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

Write-Output "Wallpaper y Lockscreen aplicados"