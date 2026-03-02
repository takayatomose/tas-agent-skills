# install.ps1 — Install tas-agent CLI on Windows
#
# Usage (run in PowerShell as Administrator or with -Scope CurrentUser):
#   irm https://raw.githubusercontent.com/hiimtrung/ai-agent-ide/main/install.ps1 | iex
#   & ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/hiimtrung/ai-agent-ide/main/install.ps1'))) -Version v0.1.0
#
param(
    [string]$Version = "",
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\tas-agent"
)

$ErrorActionPreference = "Stop"
$Repo    = "hiimtrung/ai-agent-ide"
$Binary  = "tas-agent"
$Asset   = "${Binary}-windows-amd64.exe"

# ── Resolve version ────────────────────────────────────────────────────────────
if (-not $Version) {
    Write-Host "Fetching latest release..."
    $release = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest"
    $Version = $release.tag_name
    if (-not $Version) {
        Write-Error "Failed to fetch latest version from GitHub."
        exit 1
    }
}

Write-Host "Installing $Binary $Version (windows/amd64)..."

# ── Download ───────────────────────────────────────────────────────────────────
$DownloadUrl = "https://github.com/$Repo/releases/download/$Version/$Asset"
$TmpFile     = [System.IO.Path]::GetTempFileName() + ".exe"

Write-Host "Downloading: $DownloadUrl"
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TmpFile -UseBasicParsing
} catch {
    Write-Error "Download failed. Check that release $Version exists: https://github.com/$Repo/releases"
    exit 1
}

# ── Install ────────────────────────────────────────────────────────────────────
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

$Dest = Join-Path $InstallDir "${Binary}.exe"
Move-Item -Path $TmpFile -Destination $Dest -Force

# Add to PATH for current user if not already present
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    Write-Host "Added $InstallDir to your PATH (restart your terminal to take effect)"
}

Write-Host ""
Write-Host "✓ Installed: $Dest"
Write-Host ""
Write-Host "Get started:"
Write-Host "  $Binary install be        # backend project"
Write-Host "  $Binary install fe        # frontend project"
Write-Host "  $Binary install fullstack # full-stack project"
Write-Host "  $Binary list              # see all options"
