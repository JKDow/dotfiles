#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# CONFIG - EDIT THIS
# ──────────────────────────────────────────────────────────────────────────────
REPO_URL="https://github.com/jkdow/dotfiles.git"
REPO_DIR="${HOME}/dotfiles"
PLAYBOOK_PATH="setup/bootstrap.yml"
COLLECTIONS_REQ="setup/collections/requirements.yml"

# ──────────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────────

msg()  { printf '\033[1;36m[bootstrap]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[bootstrap]\033[0m %s\n' "$*" >&2; }
die()  { err "$@"; exit 1; }

# ──────────────────────────────────────────────────────────────────────────────
# Sanity checks
# ──────────────────────────────────────────────────────────────────────────────

if [[ "$EUID" -eq 0 ]]; then
  die "Do not run this script as root. Run as your user with sudo access."
fi

if ! command -v sudo &>/dev/null; then
  die "sudo not found. Install and configure sudo first."
fi

if [[ ! -f /etc/arch-release ]]; then
  die "This bootstrap script is currently tailored for Arch Linux."
fi

# ──────────────────────────────────────────────────────────────────────────────
# Ensure core packages: git + ansible
# ──────────────────────────────────────────────────────────────────────────────

msg "Installing core packages (git, ansible) with pacman..."
sudo pacman -S --needed --noconfirm git ansible base-devel

# ──────────────────────────────────────────────────────────────────────────────
# Clone or update dotfiles repo
# ──────────────────────────────────────────────────────────────────────────────

if [[ -d "$REPO_DIR/.git" ]]; then
  msg "Dotfiles repo already present at $REPO_DIR, pulling latest..."
  git -C "$REPO_DIR" pull --ff-only || die "Failed to update existing repo."
else
  msg "Cloning dotfiles repo into $REPO_DIR..."
  git clone "$REPO_URL" "$REPO_DIR" || die "Failed to clone repo."
fi

cd "$REPO_DIR"

# ──────────────────────────────────────────────────────────────────────────────
# Ensure ansible.cfg (optional but recommended)
# ──────────────────────────────────────────────────────────────────────────────

if [[ ! -f ansible.cfg ]]; then
  msg "Creating minimal ansible.cfg..."
  cat > ansible.cfg << 'EOF'
[defaults]
inventory = ./setup/inventory.ini
collections_paths = ./collections:~/.ansible/collections:/usr/share/ansible/collections
host_key_checking = False
EOF
fi

# Ensure a simple localhost inventory if missing
if [[ ! -f setup/inventory.ini ]]; then
  msg "Creating localhost inventory..."
  mkdir -p setup
  cat > setup/inventory.ini << 'EOF'
[local]
localhost ansible_connection=local
EOF
fi

# ──────────────────────────────────────────────────────────────────────────────
# Install required collections (e.g. kewlfft.aur)
# ──────────────────────────────────────────────────────────────────────────────

if [[ -f "$COLLECTIONS_REQ" ]]; then
  msg "Installing Ansible collections from $COLLECTIONS_REQ..."
  ansible-galaxy collection install -r "$COLLECTIONS_REQ"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Run the bootstrap playbook
# ──────────────────────────────────────────────────────────────────────────────

if [[ ! -f "$PLAYBOOK_PATH" ]]; then
  die "Playbook not found at $PLAYBOOK_PATH"
fi

msg "Running Ansible bootstrap playbook..."
ansible-playbook "$PLAYBOOK_PATH" -K

msg "Bootstrap complete"

