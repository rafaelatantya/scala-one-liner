<#
.SYNOPSIS
Otomatisasi instalasi Scala 3, Java, dan SBT (Bypass Winget Edition)
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERROR] Tolong jalankan PowerShell pakai 'Run as Administrator' ya!" -ForegroundColor Red
    Exit
}

Write-Host "[INFO] Memulai setup environment Scala..." -ForegroundColor Cyan

# 1. Setup Folder Dinamis
$docPath = [Environment]::GetFolderPath('MyDocuments')
$workspace = Join-Path $docPath "scala-folder"

Write-Host "`n[PROSES] Menyiapkan working folder di: $workspace" -ForegroundColor Yellow
if (-not (Test-Path $workspace)) {
    New-Item -ItemType Directory -Force -Path $workspace | Out-Null
}
Set-Location $workspace

Write-Host "`n[PROSES] Cek dan Setup Java JVM, Scala 3, dan SBT..." -ForegroundColor Yellow

# 2. BYPASS WINGET: Download langsung installer resmi dari server Scala
if (-not (Get-Command cs -ErrorAction SilentlyContinue)) {
    Write-Host "-> Mendownload installer resmi (Coursier)..." -ForegroundColor Cyan
    $csUrl = "https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-win32.zip"
    $zipPath = Join-Path $workspace "cs.zip"
    $extractPath = Join-Path $workspace "cs-temp"
    
    Invoke-WebRequest -Uri $csUrl -OutFile $zipPath
    
    Write-Host "-> Mengekstrak installer..." -ForegroundColor Cyan
    if (Test-Path $extractPath) { Remove-Item -Recurse -Force $extractPath }
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    
    # Cari file .exe di dalem foldernya dan langsung jalankan
    $csExe = Get-ChildItem -Path $extractPath -Filter "*.exe" | Select-Object -First 1
    
    if ($csExe) {
        Write-Host "-> Menjalankan setup otomatis..." -ForegroundColor Cyan
        & $csExe.FullName setup --yes
    } else {
        Write-Host "[ERROR] Gagal mengekstrak installer!" -ForegroundColor Red
        Exit
    }
    
    # Bersihin file sampah zip dan folder ekstrak
    Write-Host "-> Membersihkan file temporary..." -ForegroundColor Cyan
    Remove-Item -Path $zipPath -Force
    Remove-Item -Recurse -Force $extractPath
} else {
    Write-Host "-> Coursier sudah ada, mengecek update requirement..." -ForegroundColor Green
    cs setup --yes
}

# 3. Setup Struktur Project SBT
Write-Host "`n[PROSES] Membuat pondasi project Scala..." -ForegroundColor Yellow
$sbtFile = "build.sbt"
if (-not (Test-Path $sbtFile)) {
    Set-Content -Path $sbtFile -Value 'scalaVersion := "3.3.3"'
}

$srcPath = "src\main\scala"
if (-not (Test-Path $srcPath)) {
    New-Item -ItemType Directory -Force -Path $srcPath | Out-Null
}

$mainFile = "$srcPath\Main.scala"
if (-not (Test-Path $mainFile)) {
    Set-Content -Path $mainFile -Value "@main def hello() = println(`"Halo dari Scala 3!`")"
}

# 4. Selesai dan Buka VS Code
Write-Host "`n[SELESAI] Setup berhasil!" -ForegroundColor Green
Write-Host "[PENTING] Setelah ini terbuka di VS Code, silakan TUTUP jendela PowerShell ini dan BUKA PowerShell baru agar command Scala/SBT bisa dipakai." -ForegroundColor Magenta

if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Host "Membuka VS Code..." -ForegroundColor Cyan
    code .
} else {
    Write-Host "[INFO] Buka folder $workspace di VS Code secara manual." -ForegroundColor Cyan
}
