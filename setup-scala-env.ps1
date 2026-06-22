<#
.SYNOPSIS
Otomatisasi instalasi dan setup environment Scala 3, Java (JVM), dan SBT di Windows.
Mendukung inisialisasi struktur folder otomatis untuk VS Code.
#>

# 1. Mengecek Hak Akses Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERROR] Tolong jalankan PowerShell pakai 'Run as Administrator' ya!" -ForegroundColor Red
    Exit
}

Write-Host "[INFO] Memulai setup environment Scala..." -ForegroundColor Cyan

# 2. Setup Folder Dinamis (Aman untuk beda nama user PC)
$docPath = [Environment]::GetFolderPath('MyDocuments')
$workspace = Join-Path $docPath "scala-folder"

Write-Host "`n[PROSES] Menyiapkan working folder di: $workspace" -ForegroundColor Yellow
if (-not (Test-Path $workspace)) {
    New-Item -ItemType Directory -Force -Path $workspace | Out-Null
    Write-Host "[OK] Folder baru berhasil dibuat!" -ForegroundColor Green
} else {
    Write-Host "[OK] Folder sudah ada, aman diloncati." -ForegroundColor Green
}
Set-Location $workspace

# 3. Cek & Install Coursier via Winget (Installer Resmi)
Write-Host "`n[PROSES] Mengecek instalasi Coursier..." -ForegroundColor Yellow
if (-not (Get-Command cs -ErrorAction SilentlyContinue)) {
    Write-Host "[PROSES] Coursier tidak ditemukan. Menginstall via Winget..." -ForegroundColor Yellow
    winget install coursier.coursier --accept-source-agreements --accept-package-agreements | Out-Null
} else {
    Write-Host "[OK] Coursier sudah terpasang." -ForegroundColor Green
}

# 4. Setup Java, Scala, & SBT otomatis via Coursier
Write-Host "`n[PROSES] Cek dan Setup Java JVM, Scala 3, dan SBT..." -ForegroundColor Yellow
# Command ini otomatis ngecek versi terbaru dan skip proses kalau file sudah ada
cs setup --yes

# Memastikan Path temporary sesi ini ter-update agar bisa ngecek versi
$coursierBin = Join-Path $env:LOCALAPPDATA "Coursier\data\bin"
if ($env:Path -notmatch [regex]::Escape($coursierBin)) {
    $env:Path += ";$coursierBin"
}

# 5. Verifikasi Instalasi & Cek Versi
Write-Host "`n[VERIFIKASI] Mengecek versi tool yang terinstall:" -ForegroundColor Cyan
try {
    Write-Host "-> Versi Java:" -ForegroundColor Magenta
    java -version
    Write-Host "`n-> Versi Scala:" -ForegroundColor Magenta
    scala -version
    Write-Host "`n-> Versi SBT:" -ForegroundColor Magenta
    sbt --script-version
    Write-Host "`n[OK] Semua komponen inti berhasil diverifikasi!" -ForegroundColor Green
} catch {
    Write-Host "`n[WARN] Gagal nge-print versi. Biasanya gara-gara Path belum ngereset. Nanti restart terminal aja." -ForegroundColor Yellow
}

# 6. Setup Struktur Project SBT (Biar deteksi plugin Metals di VS Code jalan)
Write-Host "`n[PROSES] Membuat struktur project dasar..." -ForegroundColor Yellow
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
Write-Host "[OK] Struktur project SBT siap." -ForegroundColor Green

# 7. Buka VS Code
Write-Host "`n[SELESAI] Membuka VS Code..." -ForegroundColor Green
if (Get-Command code -ErrorAction SilentlyContinue) {
    code .
} else {
    Write-Host "[INFO] Silakan buka folder $workspace di VS Code secara manual." -ForegroundColor Cyan
}
