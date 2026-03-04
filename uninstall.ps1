# uninstall.ps1 — Uninstall tas-agent CLI on Windows
#
# Usage:
#   .\uninstall.ps1 -ClearData
#   .\uninstall.ps1 -KeepData

param(
    [switch]$ClearData = $false,
    [switch]$KeepData = $false
)

$Binary = "tas-agent"
$InstallDir = "$env:LOCALAPPDATA\Programs\tas-agent"
$DataDir = "$env:USERPROFILE\.tas-agent"

# Default behavior: keep data if no switch is provided
if ($KeepData) { $ClearData = $false }

$Dest = Get-Command $Binary -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $Dest) {
    $Dest = Join-Path $InstallDir "$Binary.exe"
}

if (Test-Path $Dest) {
    Write-Host "Uninstalling $Binary from $Dest..."
    Remove-Item -Path $Dest -Force
    Write-Host "✓ Binary removed."
} else {
    Write-Host "⚠ $Binary not found. It might already be uninstalled."
}

if ($ClearData) {
    if (Test-Path $DataDir) {
        Write-Host "Clearing local data at $DataDir..."
        Remove-Item -Path $DataDir -Recurse -Force
        Write-Host "✓ Local data cleared."
    } else {
        Write-Host "No local data found at $DataDir."
    }
} else {
    Write-Host "Keeping local data at $DataDir."
}

# Remove from PATH if it was added to $InstallDir
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -like "*$InstallDir*") {
    $NewPath = ($UserPath -split ";" | Where-Object { $_ -ne $InstallDir }) -join ";"
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
    Write-Host "Removed $InstallDir from your PATH."
}

Write-Host ""
Write-Host "✓ $Binary has been uninstalled."
