#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
BIN_NAME="hyprbinds"
BUILD_DIR="target/release"

# Ensure rust installed and source cargo
if [ -f "$HOME/.cargo/env" ]; then
    source $HOME/.cargo/env
else
    echo "Error: Rust not installed"
    exit 1
fi

# --- ARG CHECK ---
if [[ $# -lt 1 ]]; then
  # echo "Usage: $0 <install_destination>"
  # echo "Example: $0 ~/.local/bin"
  exit 1
fi
DEST="$1"

# --- LOCATE PROJECT ROOT ---
# Resolve this script's absolute directory, even when symlinked
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# --- BUILD ---
# echo "→ Building release binary from: $PROJECT_ROOT"
(
  cd "$PROJECT_ROOT"
  cargo build --release
)

# --- VERIFY BUILD ---
SRC="$PROJECT_ROOT/$BUILD_DIR/$BIN_NAME"
if [[ ! -f "$SRC" ]]; then
  echo "Error: binary not found at $SRC"
  exit 1
fi

# --- INSTALL ---
mkdir -p "$DEST"
# echo "→ Installing $BIN_NAME to $DEST"
cp "$SRC" "$DEST/$BIN_NAME"
chmod +x "$DEST/$BIN_NAME"

# --- SUMMARY ---
# echo "✅ Installed: $DEST/$BIN_NAME"
# echo "   (built from $PROJECT_ROOT)"
