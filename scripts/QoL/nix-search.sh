# This script resolves the absolute path of an executable to its real location in the Nix Store.
# It bypasses symlinks to show exactly which package version is currently being used.

if [ -z "$1" ]; then
    echo "Usage: nsearch <executable_name>"
    exit 1
fi

TARGET=$(which "$1" 2>/dev/null)

if [ -z "$TARGET" ]; then
    echo "Error: '$1' not found in PATH"
    exit 1
fi

readlink -f "$TARGET"