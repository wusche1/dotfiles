#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        echo "Backing up existing $dest to $dest.backup"
        mv "$dest" "$dest.backup"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "Linked $src -> $dest"
}

echo "Installing dotfiles..."

# zsh
link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# git
link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# claude
link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
link "$DOTFILES_DIR/claude/rules" "$HOME/.claude/rules"
link "$DOTFILES_DIR/claude/agents" "$HOME/.claude/agents"
link "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"

# vscode
if [[ "$OSTYPE" == "darwin"* ]]; then
    VSCODE_DIR="$HOME/Library/Application Support/Code/User"
else
    VSCODE_DIR="$HOME/.config/Code/User"
fi
link "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_DIR/settings.json"
# vscode-server (for remote SSH connections)
if [ -d "$HOME/.vscode-server/data/User" ]; then
    link "$DOTFILES_DIR/vscode/settings.json" "$HOME/.vscode-server/data/User/settings.json"
fi

# secrets
if ls "$DOTFILES_DIR/secrets"/*.env.age 1>/dev/null 2>&1; then
    echo "Decrypting secrets..."
    "$DOTFILES_DIR/secrets/decrypt.sh"
else
    echo "No encrypted secrets found. Create ~/.secrets/*.env files and run secrets/encrypt.sh"
    mkdir -p "$HOME/.secrets"
    chmod 700 "$HOME/.secrets"
fi

# git credentials (from GITHUB_TOKEN in secrets)
if [ -f "$HOME/.secrets/personal.env" ]; then
    source "$HOME/.secrets/personal.env"
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "https://token:${GITHUB_TOKEN}@github.com" > "$HOME/.git-credentials"
        chmod 600 "$HOME/.git-credentials"
        echo "Configured git credentials"
    fi
fi

echo "Done!"
