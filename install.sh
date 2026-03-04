#!/bin/sh
# install.sh — Install tas-agent CLI
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/takayatomose/tas-agent-skills/main/install.sh | sh
#   curl -fsSL https://raw.githubusercontent.com/takayatomose/tas-agent-skills/main/install.sh | sh -s -- --version v0.1.0
#   curl -fsSL https://raw.githubusercontent.com/takayatomose/tas-agent-skills/main/install.sh | sh -s -- --dir ~/.local/bin

set -e

REPO="takayatomose/tas-agent-skills"
BINARY="tas-agent"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
VERSION=""

# ── Detect platform ───────────────────────────────────────────────────────────

OS="$(uname -s)"
ARCH="$(uname -m)"

# ── Dependencies ──────────────────────────────────────────────────────────────

check_dependencies() {
  echo "Checking dependencies..."
  
  # Python3 check
  if command -v python3 >/dev/null 2>&1; then
    echo "✓ Python3 is installed ($(python3 --version))"
  else
    echo "⚠ Python3 is not installed. Attempting to install..."
    if [ "$OS" = "Darwin" ]; then
      if command -v brew >/dev/null 2>&1; then
        brew install python
      else
        echo "Error: Homebrew is required to install Python. Please install it first: https://brew.sh"
        exit 1
      fi
    elif [ "$OS" = "Linux" ]; then
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y python3
      else
        echo "Error: Unknown Linux distribution. Please install python3 manually."
        exit 1
      fi
    fi
  fi

  # Ollama check
  if command -v ollama >/dev/null 2>&1; then
    echo "✓ Ollama is installed ($(ollama --version))"
  else
    echo "⚠ Ollama is not installed. Attempting to install..."
    if [ "$OS" = "Darwin" ]; then
      if command -v brew >/dev/null 2>&1; then
        brew install --cask ollama
      else
        echo "Please install Ollama from https://ollama.com"
        exit 1
      fi
    elif [ "$OS" = "Linux" ]; then
      curl -fsSL https://ollama.com/install.sh | sh
    fi
  fi
}

check_dependencies

# ── Detect platform ───────────────────────────────────────────────────────────

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Linux)  GOOS="linux" ;;
  Darwin) GOOS="darwin" ;;
  *)
    echo "Unsupported OS: $OS"
    echo "Please download manually from https://github.com/$REPO/releases"
    exit 1
    ;;
esac

case "$ARCH" in
  x86_64|amd64) GOARCH="amd64" ;;
  arm64|aarch64) GOARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    echo "Please download manually from https://github.com/$REPO/releases"
    exit 1
    ;;
esac

ASSET_NAME="${BINARY}-${GOOS}-${GOARCH}"

# ── Resolve version ───────────────────────────────────────────────────────────

if [ -z "$VERSION" ]; then
  echo "Fetching latest release..."
  VERSION="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')"
  if [ -z "$VERSION" ]; then
    echo "Error: failed to fetch latest version from GitHub."
    exit 1
  fi
fi

echo "Installing ${BINARY} ${VERSION} (${GOOS}/${GOARCH})..."

# ── Download ──────────────────────────────────────────────────────────────────

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET_NAME}"
TMP_FILE="$(mktemp)"

echo "Downloading: ${DOWNLOAD_URL}"
if ! curl -fsSL "$DOWNLOAD_URL" -o "$TMP_FILE"; then
  echo "Error: download failed."
  echo "Check that release ${VERSION} exists: https://github.com/${REPO}/releases"
  rm -f "$TMP_FILE"
  exit 1
fi

chmod +x "$TMP_FILE"

# ── Install ───────────────────────────────────────────────────────────────────

DEST="${INSTALL_DIR}/${BINARY}"

# Ensure INSTALL_DIR exists
mkdir -p "$INSTALL_DIR" 2>/dev/null || true

# Try to move to destination; use sudo if needed
if mv "$TMP_FILE" "$DEST" 2>/dev/null; then
  :
else
  # No permission; try with sudo
  echo "Installing to $INSTALL_DIR requires elevated permissions..."
  sudo mv "$TMP_FILE" "$DEST"
fi

echo ""
echo "✓ Installed: ${DEST}"
echo ""

# ── Initialize Config ─────────────────────────────────────────────────────────

CONFIG_DIR="$HOME/.tas-agent"
CONFIG_FILE="$CONFIG_DIR/config.json"

if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR"
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Initializing default config at $CONFIG_FILE..."
  cat <<EOF > "$CONFIG_FILE"
{
  "memory": {
    "provider": "openai",
    "base_url": "http://localhost:11434/v1",
    "model": "nomic-embed-text",
    "api_key": "ollama"
  }
}
EOF
fi

# ── Verify ────────────────────────────────────────────────────────────────────

if command -v "$BINARY" >/dev/null 2>&1; then
  "$BINARY" version
else
  echo "Note: '${INSTALL_DIR}' may not be in your PATH."
  echo "Add this to your shell profile:"
  echo "  export PATH=\"\$PATH:${INSTALL_DIR}\""
fi

echo ""
echo "Get started:"
echo "  ${BINARY} install be        # backend project"
echo "  ${BINARY} install fe        # frontend project"
echo "  ${BINARY} install fullstack # full-stack project"
echo "  ${BINARY} list              # see all options"
