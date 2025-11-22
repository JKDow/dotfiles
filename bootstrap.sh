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

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [-- additional ansible-playbook args]

Options:
  -t TAGS   Run playbook only for the given tags (comma-separated or quoted list).
            Example: -t "core,fonts"  →  ansible-playbook --tags "core,fonts"

  -n TAGS   Skip the given tags (comma-separated or quoted list).
            Example: -n "desktop"     →  ansible-playbook --skip-tags "desktop"

  -i        Interactive tag selection:
              - Lists all tags in ${PLAYBOOK_PATH}
              - Lets you select which tags to run
              - Uses fzf multi-select if available, otherwise a simple numbered prompt

  -l        List all tags in the playbook and exit.

  -h        Show this help and exit.

Examples:
  Run everything:
    $(basename "$0")

  Run only 'core' and 'dev' tags:
    $(basename "$0") -t core,dev

  Skip 'desktop' tag:
    $(basename "$0") -n desktop

  Interactive tag selection:
    $(basename "$0") -i

You can also pass extra ansible-playbook flags after --, for example:
  $(basename "$0") -t core -- --check -v
EOF
}

# ──────────────────────────────────────────────────────────────────────────────
# Option parsing
# ──────────────────────────────────────────────────────────────────────────────

TAGS=""
SKIP_TAGS=""
INTERACTIVE=0
LIST_TAGS=0

while getopts ":t:n:ilh" opt; do
  case "$opt" in
    t) TAGS="$OPTARG" ;;
    n) SKIP_TAGS="$OPTARG" ;;
    i) INTERACTIVE=1 ;;
    l) LIST_TAGS=1 ;;
    h) usage; exit 0 ;;
    :)
      die "Option -$OPTARG requires an argument."
      ;;
    \?)
      die "Invalid option: -$OPTARG (use -h for help)."
      ;;
  esac
done
shift $((OPTIND - 1))

EXTRA_ANSIBLE_ARGS=("$@")

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
# Tag utilities
# ──────────────────────────────────────────────────────────────────────────────

get_all_tags() {
  # Prints a unique list of tags, one per line, to stdout.
  # Uses "ansible-playbook --list-tags" and scrapes TASK TAGS lines.
  local output
  if ! output=$(ansible-playbook "$PLAYBOOK_PATH" --list-tags 2>/dev/null); then
    return 1
  fi

  # Extract content inside [ ] after "TASK TAGS:"
  # Then split on commas, trim whitespace, dedupe, sort.
  awk -F'[][]' '/TASK TAGS:/ {print $2}' <<< "$output" \
    | tr ',' '\n' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
    | sed '/^$/d' \
    | sort -u
}

if (( LIST_TAGS == 1 )); then
  msg "Listing available tags in $PLAYBOOK_PATH..."
  if tags=$(get_all_tags); then
    echo "$tags"
    exit 0
  else
    die "Could not retrieve tags."
  fi
fi

interactive_select_tags() {
  msg "Discovering tags from playbook (ansible-playbook --list-tags)..."

  local tags
  if ! tags=$(get_all_tags); then
    err "Could not retrieve tags (maybe playbook has syntax errors?)."
    return 1
  fi

  if [[ -z "$tags" ]]; then
    err "No tags found in playbook."
    return 1
  fi

  # Convert to array
  mapfile -t tag_array <<< "$tags"

  # Prefer fzf if available for multi-select
  if command -v fzf >/dev/null 2>&1; then
    msg "Using fzf for interactive multi-select (TAB to toggle, ENTER to confirm, ESC to cancel)."
    # set +e is not needed since inside if, but ensure we don't die on ESC
    local selected
    if ! selected=$(printf '%s\n' "${tag_array[@]}" | fzf -m --prompt="Select tags> "); then
      err "No tags selected (fzf aborted)."
      return 1
    fi
    # join with commas
    selected=$(tr '\n' ',' <<< "$selected" | sed 's/,$//')
    [[ -z "$selected" ]] && { err "No tags selected."; return 1; }
    TAGS="$selected"
    return 0
  fi

  # Fallback: simple numbered list + prompt
  msg "fzf not found; using simple numbered selection."
  echo "Available tags:"
  local i=1
  for t in "${tag_array[@]}"; do
    printf "  %2d) %s\n" "$i" "$t"
    ((i++))
  done
  echo
  echo "Enter tag numbers separated by spaces (e.g. '1 3 5'), or press ENTER to cancel."
  read -r -p "Selection: " choices || true

  if [[ -z "${choices:-}" ]]; then
    err "No tags selected."
    return 1
  fi

  local idx sel_tags=()
  for idx in $choices; do
    # ensure it is numeric and in range
    if [[ "$idx" =~ ^[0-9]+$ ]] && (( idx >= 1 && idx <= ${#tag_array[@]} )); then
      sel_tags+=("${tag_array[idx-1]}")
    else
      err "Ignoring invalid selection: $idx"
    fi
  done

  if [[ ${#sel_tags[@]} -eq 0 ]]; then
    err "No valid tags selected."
    return 1
  fi

  # join selected tags with commas
  local joined
  joined=$(printf '%s,' "${sel_tags[@]}")
  joined=${joined%,} # strip trailing comma
  TAGS="$joined"
}

# ──────────────────────────────────────────────────────────────────────────────
# Run the bootstrap playbook
# ──────────────────────────────────────────────────────────────────────────────

if [[ ! -f "$PLAYBOOK_PATH" ]]; then
  die "Playbook not found at $PLAYBOOK_PATH"
fi

# If interactive mode requested, populate TAGS (unless user already set them)
if (( INTERACTIVE == 1 )); then
  if [[ -n "$TAGS" ]]; then
    msg "Both -t and -i provided; -i (interactive) will override -t."
  fi
  if ! interactive_select_tags; then
    die "Interactive tag selection failed; aborting."
  fi
  msg "Selected tags: $TAGS"
fi

msg "Running Ansible bootstrap playbook..."

PLAYBOOK_CMD=(ansible-playbook "$PLAYBOOK_PATH" -K)

if [[ -n "$TAGS" ]]; then
  PLAYBOOK_CMD+=(--tags "$TAGS")
fi

if [[ -n "$SKIP_TAGS" ]]; then
  PLAYBOOK_CMD+=(--skip-tags "$SKIP_TAGS")
fi

# Append any extra ansible-playbook args after --
if [[ ${#EXTRA_ANSIBLE_ARGS[@]} -gt 0 ]]; then
  PLAYBOOK_CMD+=("${EXTRA_ANSIBLE_ARGS[@]}")
fi

# Show the final command for visibility
msg "Executing: ${PLAYBOOK_CMD[*]}"
"${PLAYBOOK_CMD[@]}"

msg "Bootstrap complete"

