#!/bin/bash

RC_FILE="${HOME}/.bashrc"
[ -f "${HOME}/.zshrc" ] && RC_FILE="${HOME}/.zshrc"

grep -q "source ~/dotfiles/aliases.sh" "$RC_FILE" || echo "source ~/dotfiles/aliases.sh" >> "$RC_FILE"

mkdir -p ~/sky_workdir/.vscode
cp ~/dotfiles/tasks.json ~/sky_workdir/.vscode/tasks.json

echo "✅ Done"
