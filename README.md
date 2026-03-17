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

## Workflow

The goal is maximally parallelized Claude Code integration — working on many things at once, easily switching between them, with full file visibility via neovim while Claude does its thing without interference.

### Tools

- **[Ghostty](https://ghostty.org/)** as the terminal
- **tmux** for session and window management
- **neovim** (LazyVim) for viewing and editing files
- **Claude Code** (`cc`) for AI-assisted development

Vim-style `hjkl` navigation works at every layer: Ghostty splits (`Opt+hjkl`), tmux panes (`prefix+hjkl`), and neovim.

### One project = one tmux session

Each project (repo) lives in its own tmux session. Create a new one with `prefix S`, which prompts for a name and opens it in `~/Projects`.

### One feature = one worktree + one tmux window

Within a project, each feature gets its own git branch **and** its own [git worktree](https://git-scm.com/docs/git-worktree), so you never need to stash or switch branches. Press `prefix W`, enter a name, and a new branch, worktree, and tmux window are created automatically. The `.venv` from the main repo is symlinked into each worktree so you don't reinstall dependencies.

This clean separation — every issue on its own branch in its own directory — means you can run Claude Code independently in each window without any interference between tasks.

### Remote development

For work that's better done on a remote machine (e.g. GPU training on RunPod), keep a local tmux session called `remote` and SSH in:

```bash
remote ssh root@213.192.2.99 -p 40110 -i ~/.ssh/id_ed25519
```

The `remote` function clones your dotfiles on the remote, runs `setup-remote.sh` (installs zsh, tmux, neovim, claude-code, etc.), then drops you into a tmux session. You pick a project and optionally a worktree branch — the same session/worktree workflow works identically on the remote.

Press `F12` to toggle local tmux off so your `Ctrl+Space` prefix passes through to the remote tmux session. Press `F12` again to re-enable local tmux.

### Claude Code

Run Claude Code with `cc`. For autonomous operation, `ccdsp` starts Claude with all tool permissions auto-allowed (a workaround for remote machines where `--dangerously-skip-permissions` requires root privileges that aren't available on e.g. RunPod).

Secrets are age-encrypted in the repo and decrypted on install using your SSH key, so Claude Code gets its API keys automatically on any machine after running `install.sh`.
