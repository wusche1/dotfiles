#!/bin/bash

RC_FILE="${HOME}/.bashrc"
[ -f "${HOME}/.zshrc" ] && RC_FILE="${HOME}/.zshrc"

grep -q "source ~/dotfiles/aliases.sh" "$RC_FILE" || echo "source ~/dotfiles/aliases.sh" >> "$RC_FILE"

DOTFILES_DIR="${HOME}/dotfiles"
WORKSPACES_DIR="${DOTFILES_DIR}/workspaces"
TARGET_DIR="${HOME}/sky_workdir"

if [ -d "$WORKSPACES_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    for folder in "$WORKSPACES_DIR"/*; do
        if [ -d "$folder" ]; then
            folder_name=$(basename "$folder")
            target_path="$TARGET_DIR/.${folder_name}"
            mkdir -p "$target_path"
            cp -r "$folder/"* "$target_path/"
        fi
    done
fi
