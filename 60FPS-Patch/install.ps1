param(
    [string]$GameDir = "F:\sloner\BBB\Command & Conquer 3 Kane's Wrath\RetailExe\1.0",
    [int]$Fps = 60
)

$ErrorActionPreference = "Stop"
$bin = Join-Path $PSScriptRoot "bin"

if (-not (Test-Path (Join-Path $GameDir "cnc3ep1.dat"))) {
    throw "cnc3ep1.dat not found in $GameDir. Pass -GameDir <RetailExe\1.0>."
}
$running = Get-Process cnc3ep1.dat -ErrorAction SilentlyContinue
if ($running -and ((Split-Path $running.Path -ErrorAction SilentlyContinue) -eq (Resolve-Path $GameDir).Path)) {
    Write-Warning "The game in $GameDir is running. Close it first; the DLL cannot be replaced while loaded."
    exit 1
}

$dll = Join-Path $GameDir "dinput8.dll"
if (Test-Path $dll) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $bak = Join-Path $GameDir "dinput8.dll.bak-$stamp"
    Copy-Item $dll $bak
    Write-Host "Existing dinput8.dll backed up to $bak"
}

Copy-Item (Join-Path $bin "dinput8.dll")         $GameDir -Force
Copy-Item (Join-Path $bin "CnCFpsUnlocker.dll") $GameDir -Force
Copy-Item (Join-Path $bin "SAGEUnlocked.ini")   $GameDir -Force

$ini = Join-Path $GameDir "SAGEUnlocked.ini"
$text = Get-Content $ini -Raw
if ($text -match "(?m)^\s*fps\s*=") {
    $text = $text -replace "(?m)^\s*fps\s*=.*$", "fps=$Fps"
} else {
    $text += "`r`nfps=$Fps`r`n"
}
Set-Content -Path $ini -Value $text -Encoding ASCII

Write-Host "Installed frame-rate patch to $GameDir (fps=$Fps)."
Write-Host "Launch cnc3ep1.exe normally. Log: SAGEUnlocked.log in the same folder."


