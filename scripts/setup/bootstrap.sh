#!/usr/bin/env bash
# usage: ./bootstrap.sh [hostname] [path/to/local/repo]
# If no repo path is provided, the script will clone automatically.
# Run with: sudo ./bootstrap.sh [hostname] [repo_path]

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================
readonly REPO_URL="https://github.com/accrrsd/myNixos.git"
readonly REPO_BRANCH="main"
readonly CONFIG_DIR="/nixos-config"

# Arguments: hostname first (more common), repo path second (rare)
HOSTNAME="${1:-default-pc}"
GIT_REPO_PATH="${2:-}"
GROUP="nixos-editors"

# Derived paths
HOST_DIR="$CONFIG_DIR/systems/$HOSTNAME"
FLAKE_DIR="$HOST_DIR/flake"
HW_FILE="$FLAKE_DIR/hardware-configuration.nix"

# =============================================================================
# HELPERS
# =============================================================================
log_info()  { echo -e "\e[34m[→]\e[0m $*"; }
log_ok()    { echo -e "\e[32m[✓]\e[0m $*"; }
log_warn()  { echo -e "\e[33m[!]\e[0m $*"; }
log_err()   { echo -e "\e[31m[✗]\e[0m $*" >&2; }

# =============================================================================
# [0] REPOSITORY SETUP
# =============================================================================
echo -e "\n\e[1m=== 🚀 NixOS Bootstrap: $HOSTNAME ===\e[0m\n"
echo "=== [1/5] Repository ==="

if [[ -n "$GIT_REPO_PATH" ]]; then
    if [[ ! -d "$GIT_REPO_PATH" ]]; then
        log_err "Repo path '$GIT_REPO_PATH' is not a directory"
        exit 1
    fi
    SOURCE_REPO="$GIT_REPO_PATH"
    log_ok "Using local repo: $SOURCE_REPO"
else
    SOURCE_REPO="/tmp/myNixos-bootstrap-$$"
    log_info "Cloning repo from $REPO_URL..."
    git clone --branch "$REPO_BRANCH" --depth 1 "$REPO_URL" "$SOURCE_REPO"
    log_ok "Cloned to $SOURCE_REPO"
fi

# Cleanup temp repo on exit (not /nixos-config!)
if [[ -z "$GIT_REPO_PATH" ]]; then
    trap 'rm -rf "$SOURCE_REPO"' EXIT
fi

# =============================================================================
# [1] SYNC CONFIG TO /nixos-config
# =============================================================================
echo ""
echo "=== [2/5] Config directory ==="

if [[ -d "$CONFIG_DIR/.git" ]]; then
    log_ok "$CONFIG_DIR exists — skipping sync"
else
    log_info "Initializing $CONFIG_DIR from repo..."
    cp -r "$SOURCE_REPO"/. "$CONFIG_DIR"/
    chown -R root:root "$CONFIG_DIR"
    find "$CONFIG_DIR" -type d -exec chmod 755 {} +
    find "$CONFIG_DIR" -type f -exec chmod 644 {} +
    find "$CONFIG_DIR" -name "*.sh" -type f -exec chmod 755 {} +
    log_ok "Config synced"
fi

# =============================================================================
# [2] HARDWARE-CONFIGURATION.NIX
# =============================================================================
echo ""
echo "=== [3/5] Hardware configuration ==="

if [[ -f "/etc/nixos/hardware-configuration.nix" ]]; then
    log_info "Copying system hardware config → repo..."
    mkdir -p "$(dirname "$HW_FILE")"
    cp /etc/nixos/hardware-configuration.nix "$HW_FILE"
    chmod 644 "$HW_FILE"
    log_ok "Hardware config synced"
else
    if [[ ! -f "$HW_FILE" ]]; then
        log_warn "No hardware config found — creating placeholder"
        mkdir -p "$(dirname "$HW_FILE")"
        cat > "$HW_FILE" << 'EOF'
# Placeholder hardware-configuration.nix
# REPLACE WITH OUTPUT FROM nixos-generate-config

{ config, lib, pkgs, ... }: {
  imports = [ ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_ROOT";
    fsType = "ext4";
  };
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.enable = true;
}
EOF
        log_warn "⚠️  Review $HW_FILE before rebuilding!"
    else
        log_ok "Hardware config exists in repo"
    fi
fi

# Stage in git (permanent, no cleanup)
cd "$CONFIG_DIR"
if git status --porcelain "$HW_FILE" 2>/dev/null | grep -qE "^(\?\?| M)"; then
    log_info "Staging hardware config in git..."
    git add "$HW_FILE"
    log_ok "Hardware config staged"
else
    log_ok "Hardware config already tracked"
fi

# =============================================================================
# [2.5] SET EDIT PERMISSIONS FOR GROUP
# =============================================================================
echo ""
echo "=== [3.5/5] Setting edit permissions ==="

log_info "Configuring group access for '$GROUP'..."

# Ensure group exists (create if missing)
if ! getent group "$GROUP" >/dev/null 2>&1; then
    log_info "Creating group: $GROUP"
    groupadd "$GROUP"
fi

# Set group ownership on config directory
chown -R root:"$GROUP" "$CONFIG_DIR"

# Directories: rwxrwsr-x (2775) — setgid ensures new files inherit group
find "$CONFIG_DIR" -type d -exec chmod 2775 {} +

# Files: rw-rw-r-- (664) — group can edit
find "$CONFIG_DIR" -type f -exec chmod 664 {} +

# Scripts: rwxrwxr-x (775) — executable for group
find "$CONFIG_DIR" -name "*.sh" -type f -exec chmod 775 {} +

log_ok "Permissions set: members of '$GROUP' can now edit configs in $CONFIG_DIR"

# =============================================================================
# [3] ENABLE FLAKES & REBUILD
# =============================================================================
echo ""
echo "=== [4/5] System rebuild ==="

cd "$FLAKE_DIR"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    log_err "$FLAKE_DIR is not a git repository"
    exit 1
fi

log_info "Running nixos-rebuild switch --flake .#$HOSTNAME"
log_info "This may take a while..."

sudo env NIX_CONFIG="experimental-features = nix-command flakes" \
    nixos-rebuild switch \
    --flake ".#$HOSTNAME" \
    --impure \
    --show-trace \
    --print-build-logs 2>&1 | tee -a /tmp/bootstrap-rebuild.log

if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
    log_ok "Rebuild successful!"
else
    log_err "Rebuild failed. Check /tmp/bootstrap-rebuild.log"
    exit 1
fi

# =============================================================================
# [4] HOME MANAGER
# =============================================================================
echo ""
echo "=== [5/5] Home Manager ==="

if command -v home-manager >/dev/null 2>&1; then
    log_info "Activating home-manager..."
    if home-manager switch --flake ".#$HOSTNAME" 2>/dev/null; then
        log_ok "Home Manager activated"
    else
        log_warn "Home Manager skipped (may need session restart)"
    fi
else
    log_info "Home Manager will be available after next login"
fi

# =============================================================================
# FINAL
# =============================================================================
echo ""
echo -e "\e[1;32m=== ✨ Bootstrap complete! ===\e[0m"
echo ""
echo "Next steps:"
echo "  cd $CONFIG_DIR"
echo "  git status                    # Review changes"
echo "  git commit -am 'feat: bootstrap $HOSTNAME'"
echo "  git push"
echo ""
echo "Commands:"
echo "  nixos-rebuild switch --flake $FLAKE_DIR#$HOSTNAME"
echo "  home-manager switch --flake $FLAKE_DIR#$HOSTNAME"
echo ""
