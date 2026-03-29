#!/usr/bin/env bash
# Usage: ./scripts/setup/create-ssh-github.sh <your_email@example.com>

set -euo pipefail

EMAIL="${1:-$(git config user.email 2>/dev/null || echo "")}"
KEY_TYPE="ed25519"
KEY_PATH="$HOME/.ssh/id_ed25519"

echo "=== SSH Key Setup for GitHub ==="

if [[ -z "$EMAIL" ]]; then
    read -rp "→ Enter your email for SSH key: " EMAIL
    if [[ -z "$EMAIL" ]]; then
        echo "[!] Error: Email is required" >&2
        exit 1
    fi
fi

if [[ ! -f "$KEY_PATH" ]]; then
    echo "→ Generating $KEY_TYPE key for $EMAIL..."
    ssh-keygen -t "$KEY_TYPE" -C "$EMAIL" -f "$KEY_PATH" -N ""
else
    echo "✓ Key already exists: $KEY_PATH"
fi

if command -v ssh-add &>/dev/null; then
    echo "→ Adding key to ssh-agent..."
    ssh-add "$KEY_PATH" 2>/dev/null || true
fi

echo "→ Copying public key to clipboard..."
if command -v wl-copy &>/dev/null; then
    cat "$KEY_PATH.pub" | wl-copy
    echo "✓ Public key copied (Wayland). Paste it to: https://github.com/settings/keys"
elif command -v xclip &>/dev/null; then
    cat "$KEY_PATH.pub" | xclip -selection clipboard
    echo "✓ Public key copied (X11). Paste it to: https://github.com/settings/keys"
else
    echo "⚠ No clipboard tool found. Copy manually:"
    echo "--- PUBLIC KEY START ---"
    cat "$KEY_PATH.pub"
    echo "--- PUBLIC KEY END ---"
fi

read -p "Press [Enter] to continue..."

echo ""
echo "→ Testing connection to GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "You've successfully authenticated"; then
    echo "✓ GitHub connection successful!"
else
    echo "⚠ Connection test failed. Make sure you:"
    echo "  1. Added the public key to GitHub"
    echo "  2. Accepted the host fingerprint on first connect"
fi