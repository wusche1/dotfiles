#!/bin/bash

# Encrypts secrets from ~/.secrets/ into this directory
# Run this after editing your secrets

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_KEY="$HOME/.ssh/id_ed25519.pub"

if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH public key not found at $SSH_KEY"
    exit 1
fi

echo "Encrypting secrets using $SSH_KEY..."

for file in "$HOME/.secrets"/*.env; do
    if [ -f "$file" ]; then
        name=$(basename "$file")
        age -R "$SSH_KEY" "$file" > "$SCRIPT_DIR/${name}.age"
        echo "Encrypted: $name -> ${name}.age"
    fi
done

echo "Done! Now commit the .age files."
