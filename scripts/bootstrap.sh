#!/usr/bin/env bash
# 1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 6️⃣

# usage example ./bootstrap.sh path/to/git/folder default-pc
# make sure your pc have correct boot.loader.device!

set -euo pipefail

clear

CONFIG_DIR="/nixosConfig"
GROUP="nixos-editors"
GIT_REPO_PATH="${1}"
HOSTNAME="${2:-default-pc}"
HOST_DIR="$CONFIG_DIR/systems/$HOSTNAME"
HW_FILE="$HOST_DIR/hardware-configuration.nix"

if [[ -z "${GIT_REPO_PATH:-}" ]]; then
    echo "❌ Error: GIT_REPO_PATH (first argument) is required" >&2
    exit 1
fi

if [[ ! -d "$GIT_REPO_PATH" ]]; then
    echo "❌ Error: GIT_REPO_PATH '$GIT_REPO_PATH' is not a directory" >&2
    exit 1
fi

echo "=== Bootstrap for $HOSTNAME ==="

# Configure groups, permissions, and sync repo if needed
echo ""
echo "=== 1️⃣ Check config folder ==="
# Create group if not exist
if ! getent group "$GROUP" >/dev/null; then
    echo "➡️ Creating group: $GROUP"
    sudo groupadd "$GROUP"
fi

# Add current user to group
CURRENT_USER="$(id -un)"
USER_ADDED_TO_GROUP=false
if ! groups "$CURRENT_USER" | grep -q "\b$GROUP\b"; then
    echo "➡️ Adding user '$CURRENT_USER' to group '$GROUP'"
    sudo usermod -a -G "$GROUP" "$CURRENT_USER"
    USER_ADDED_TO_GROUP=true
fi

# Create config dir
if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "➡️ CONFIG_DIR '$CONFIG_DIR' does not exist — initializing from git repo..."
    sudo mkdir -p "$CONFIG_DIR"

    echo "➡️ Copying contents from '$GIT_REPO_PATH' to '$CONFIG_DIR'..."
    sudo cp -r "$GIT_REPO_PATH"/. "$CONFIG_DIR"/

    echo "➡️ Setting ownership to $CURRENT_USER:$GROUP..."
    sudo chown -R "$CURRENT_USER:$GROUP" "$CONFIG_DIR"

    echo "➡️ Setting permissions 2775 and setgid bit..."
    sudo chmod -R 2775 "$CONFIG_DIR"
    sudo find "$CONFIG_DIR" -type d -exec chmod g+s {} +
else
    echo "✅ CONFIG_DIR '$CONFIG_DIR' already exists — skipping repo sync."
fi

echo ""
# Copy hardware-confuguration
echo "=== 2️⃣ Do hardware-configuration.nix stuff ==="
if [[ ! -f "$HW_FILE" ]]; then
    echo "➡️ Copying /etc/nixos/hardware-configuration.nix → $HW_FILE"
    sudo cp /etc/nixos/hardware-configuration.nix "$HW_FILE"
    sudo chown "$CURRENT_USER:$GROUP" "$HW_FILE"
    sudo chmod 644 "$HW_FILE"
else
    echo "✅ Hardware config already exists at $HW_FILE, skipping copy."
fi

echo ""
echo "=== 4️⃣ Preparing flake: temporarily adding hardware config to Git index ==="
cd "$HOST_DIR"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ Error: $HOST_DIR is not a Git repository. Flake requires Git for self-reference."
    exit 1
fi

git add -f "$HW_FILE" 2>/dev/null || {
    echo "❌ Error: Could not add $HW_FILE to Git index"
    exit 1
}

echo ""
echo "=== 5️⃣ Bootstrap rebuild with flakes ==="
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake .#"$HOSTNAME"

echo "=== 6️⃣ Cleaning up: removing hardware config from Git index ==="
git reset "$HW_FILE" 2>/dev/null || {
    echo "⚠️ Warning: Could not reset $HW_FILE from index — probably wasn't added. Ignoring."
}

echo "=== ✅ Bootstrap done. Welcome to your declarative NixOS system! ==="

if [[ "$USER_ADDED_TO_GROUP" == true ]]; then
    echo ""
    echo "ℹ️  User '$CURRENT_USER' was added to group '$GROUP'."
    echo "ℹ️  To edit configs immediately, run: newgrp $GROUP"
    echo "    (or log out and back in)"
fi