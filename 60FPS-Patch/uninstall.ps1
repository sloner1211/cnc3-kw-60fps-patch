param(
    [string]$GameDir = "F:\sloner\BBB\Command & Conquer 3 Kane's Wrath\RetailExe\1.0"
)

$ErrorActionPreference = "Stop"
$running = Get-Process cnc3ep1.dat -ErrorAction SilentlyContinue
if ($running -and ((Split-Path $running.Path -ErrorAction SilentlyContinue) -eq (Resolve-Path $GameDir).Path)) {
    Write-Warning "The game in $GameDir is running. Close it first."
    exit 1
}

foreach ($name in @("dinput8.dll", "CnCFpsUnlocker.dll", "SAGEUnlocked.ini")) {
    $p = Join-Path $GameDir $name
    if (Test-Path $p) {
        Remove-Item $p -Force
        Write-Host "Removed $p"
    }
}
Write-Host "Uninstalled. The game is back to its original 30 FPS."
Write-Host "If a dinput8.dll.bak-* backup exists and you had another mod, restore it manually."
