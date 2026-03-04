# install.ps1 — Install tas-agent CLI on Windows
#
# Usage (run in PowerShell as Administrator or with -Scope CurrentUser):
#   irm https://raw.githubusercontent.com/takayatomose/tas-agent-skills/main/install.ps1 | iex
#   & ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/takayatomose/tas-agent-skills/main/install.ps1'))) -Version v0.1.0
#
param(
    [string]$Version = "",
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\tas-agent"
)

$ErrorActionPreference = "Stop"
$Repo    = "takayatomose/tas-agent-skills"
$Binary  = "tas-agent"
$Asset   = "${Binary}-windows-amd64.exe"

# ── Dependencies ──────────────────────────────────────────────────────────────

function Check-Dependencies {
    Write-Host "Checking dependencies..."

    # Python3 check
    if (Get-Command "python" -ErrorAction SilentlyContinue) {
        $ver = python --version
        Write-Host "✓ Python3 is installed ($ver)"
    } else {
        Write-Host "⚠ Python3 is not installed. Attempting to install via winget..."
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            winget install -e --id Python.Python.3
        } else {
            Write-Error "winget not found. Please install Python 3 manually from https://python.org"
            exit 1
        }
    }

    # Ollama check
    if (Get-Command "ollama" -ErrorAction SilentlyContinue) {
        $ver = ollama --version
        Write-Host "✓ Ollama is installed ($ver)"
    } else {
        Write-Host "⚠ Ollama is not installed. Attempting to install via winget..."
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            winget install -e --id Ollama.Ollama
        } else {
            Write-Error "winget not found. Please install Ollama manually from https://ollama.com"
            exit 1
        }
    }

    # Start Ollama if not running
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:11434" -UseBasicParsing -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Starting Ollama in background..."
        Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
        
        # Wait for Ollama to be ready
        $maxRetries = 10
        $count = 0
        while ($true) {
            try {
                $response = Invoke-WebRequest -Uri "http://127.0.0.1:11434" -UseBasicParsing -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) { break }
            } catch {
                if ($count -ge $maxRetries) {
                    Write-Host "⚠ Timeout waiting for Ollama to start."
                    break
                }
                Start-Sleep -Seconds 1
                $count++
            }
        }
    }

    # Pull embedding model
    Write-Host "Ensuring embedding model 'nomic-embed-text' is available..."
    & ollama pull nomic-embed-text

    # Setup auto-start on reboot
    Write-Host "Setting up Ollama auto-start on reboot..."
    $startupFolder = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Startup")
    $shortcutPath = [System.IO.Path]::Combine($startupFolder, "Ollama.lnk")
    
    if (-not (Test-Path $shortcutPath)) {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = (Get-Command "ollama").Source
        $shortcut.Arguments = "serve"
        $shortcut.WindowStyle = 7 # Minimized
        $shortcut.Save()
        Write-Host "✓ Created startup shortcut for Ollama"
    }
}

Check-Dependencies

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

# ── Initialize Config ─────────────────────────────────────────────────────────

$ConfigDir = Join-Path $env:USERPROFILE ".tas-agent"
$ConfigFile = Join-Path $ConfigDir "config.json"

if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}

if (-not (Test-Path $ConfigFile)) {
    Write-Host "Initializing default config at $ConfigFile..."
    $DefaultConfig = @{
        memory = @{
            provider = "openai"
            base_url = "http://127.0.0.1:11434/v1"
            model = "nomic-embed-text"
            api_key = "ollama"
        }
    }
    $DefaultConfig | ConvertTo-Json -Depth 10 | Out-File $ConfigFile
}
Write-Host "Get started:"
Write-Host "  $Binary install be        # backend project"
Write-Host "  $Binary install fe        # frontend project"
Write-Host "  $Binary install fullstack # full-stack project"
Write-Host "  $Binary list              # see all options"
