# Dotfiles

Personal dotfiles managed with symlinks.

## Installation

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Structure

```
dotfiles/
├── zsh/.zshrc           # Zsh configuration
├── git/.gitconfig       # Git configuration
├── claude/settings.json # Claude Code settings
├── vscode/settings.json # VS Code settings
└── install.sh           # Symlink installer
```

## How it works

The install script creates symlinks from your home directory to this repo. Any changes you make to the dotfiles (either in `~` or in this repo) will be reflected in both places.
