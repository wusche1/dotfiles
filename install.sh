#!/bin/zsh

set -e

DOTFILES_DIR="$(cd "$(dirname "${0}")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"

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

# symlink repo to ~/dotfiles (skip if already there)
[[ "$DOTFILES_DIR" != "$HOME/dotfiles" ]] && link "$DOTFILES_DIR" "$HOME/dotfiles"

# zsh
link "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"
link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# git
link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# herdr
link "$DOTFILES_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml"
command -v herdr > /dev/null && for p in "$DOTFILES_DIR"/herdr/plugins/*/; do herdr plugin link "$p" > /dev/null; done

# nvim
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# ghostty
if [[ "$OSTYPE" == "darwin"* ]]; then
    GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
else
    GHOSTTY_DIR="$HOME/.config/ghostty"
fi
link "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_DIR/config"
link "$DOTFILES_DIR/ghostty/shaders" "$GHOSTTY_DIR/shaders"

# claude
link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
link "$DOTFILES_DIR/claude/rules" "$HOME/.claude/rules"
link "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"
link "$DOTFILES_DIR/claude/clipboard-mcp.py" "$HOME/.claude/clipboard-mcp.py"

# scripts
mkdir -p "$HOME/.local/bin"
link "$DOTFILES_DIR/scripts/herdr-worktree" "$HOME/.local/bin/herdr-worktree"

echo "Done!"
