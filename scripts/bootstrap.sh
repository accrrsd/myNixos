#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="/nixosConfig"
GROUP="nixos-editors"
HOSTNAME="${1:-default}"
HOST_DIR="$CONFIG_DIR/systems/$HOSTNAME"
HW_FILE="$HOST_DIR/hardware-configuration.nix"

echo "=== 1️⃣ Check and create group ==="
if ! getent group "$GROUP" >/dev/null; then
    sudo groupadd "$GROUP"
fi

echo "=== 2️⃣ Checking config folder rights ==="
sudo mkdir -p "$CONFIG_DIR"
sudo chown -R root:"$GROUP" "$CONFIG_DIR"
sudo chmod -R 2775 "$CONFIG_DIR"
sudo find "$CONFIG_DIR" -type d -exec chmod g+s {} +

echo "=== 3️⃣ Ensure hardware-configuration.nix exists ==="
if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
    echo "⚠️ Generating /etc/nixos/hardware-configuration.nix..."
    sudo mkdir -p /etc/nixos
    sudo nixos-generate-config --root /etc/nixos
fi

if [ ! -f "$HW_FILE" ]; then
    echo "Copying /etc/nixos/hardware-configuration.nix → $HW_FILE"
    sudo cp /etc/nixos/hardware-configuration.nix "$HW_FILE"
    sudo chown root:root "$HW_FILE"
    sudo chmod 644 "$HW_FILE"
else
    echo "✅ Hardware config already exists at $HW_FILE, skipping copy."
fi

echo "=== 4️⃣ Preparing flake: temporarily adding hardware config to Git index ==="
cd "$HOST_DIR"

# Проверяем, что мы в Git-репозитории
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ Error: $HOST_DIR is not a Git repository. Flake requires Git for self-reference."
    exit 1
fi

# Добавляем файл в индекс, игнорируя .gitignore
git add "$HW_FILE" 2>/dev/null || {
    echo "❌ Error Could not add $HW_FILE to Git index (maybe not in repo?)"
    exit 1
}

echo "=== 5️⃣ Bootstrap rebuild with flakes ==="
nix-shell -p nixVersions.latest --run "sudo nixos-rebuild switch --flake .#$HOSTNAME"

echo "=== 6️⃣ Cleaning up: removing hardware config from Git index ==="

git reset "$HW_FILE" 2>/dev/null || {
    echo "⚠️ Warning: Could not reset $HW_FILE from index — probably wasn't added. Ignoring."
}

echo "✅ Bootstrap done. Welcome to your declarative NixOS system!"