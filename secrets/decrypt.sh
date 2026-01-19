#!/bin/bash

# Decrypts secrets from this directory into ~/.secrets/
# Called by install.sh or run manually

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_KEY="$HOME/.ssh/id_ed25519"

if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH private key not found at $SSH_KEY"
    exit 1
fi

mkdir -p "$HOME/.secrets"
chmod 700 "$HOME/.secrets"

echo "Decrypting secrets using $SSH_KEY..."

for file in "$SCRIPT_DIR"/*.env.age; do
    if [ -f "$file" ]; then
        name=$(basename "$file" .age)
        age -d -i "$SSH_KEY" "$file" > "$HOME/.secrets/$name"
        chmod 600 "$HOME/.secrets/$name"
        echo "Decrypted: $(basename "$file") -> ~/.secrets/$name"
    fi
done

echo "Done!"
