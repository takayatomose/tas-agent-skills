#!/bin/sh
# uninstall.sh — Uninstall tas-agent CLI
#
# Usage:
#   ./uninstall.sh [--clear-data]
#   ./uninstall.sh [--keep-data]

set -e

BINARY="tas-agent"
INSTALL_DIR="/usr/local/bin"
DATA_DIR="$HOME/.tas-agent"
CLEAR_DATA=false

# ── Parse arguments ───────────────────────────────────────────────────────────

while [ $# -gt 0 ]; do
  case "$1" in
    --clear-data)
      CLEAR_DATA=true; shift ;;
    --keep-data)
      CLEAR_DATA=false; shift ;;
    --help|-h)
      echo "Usage: uninstall.sh [--clear-data|--keep-data]"
      echo "  --clear-data    Remove the binary and all local data ($DATA_DIR)"
      echo "  --keep-data     Remove the binary but keep local data (default)"
      exit 0 ;;
    *)
      echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Detect installation ───────────────────────────────────────────────────────

DEST=$(command -v $BINARY || echo "$INSTALL_DIR/$BINARY")

if [ ! -f "$DEST" ]; then
  echo "⚠ $BINARY not found at $DEST. It might already be uninstalled or installed elsewhere."
else
  echo "Uninstalling $BINARY from $DEST..."
  if rm "$DEST" 2>/dev/null; then
    echo "✓ Binary removed."
  else
    echo "Requires elevated permissions to remove $DEST..."
    sudo rm "$DEST"
    echo "✓ Binary removed."
  fi
fi

# ── Clear Local Data ─────────────────────────────────────────────────────────

if [ "$CLEAR_DATA" = true ]; then
  if [ -d "$DATA_DIR" ]; then
    echo "Clearing local data at $DATA_DIR..."
    rm -rf "$DATA_DIR"
    echo "✓ Local data cleared."
  else
    echo "No local data found at $DATA_DIR."
  fi
else
  echo "Keeping local data at $DATA_DIR."
fi

echo ""
echo "✓ $BINARY has been uninstalled."
