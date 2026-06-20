# Dotfiles

A complete terminal setup tuned for one thing: running **many Claude Code sessions in parallel** without them tripping over each other. The terminal (Ghostty), multiplexer (tmux), editor (neovim), and shell (zsh) are configured to share one mental model — every project is a session, every feature is its own branch + worktree in its own window, and `hjkl` moves you everywhere.

Everything is plain config files symlinked into place by `install.sh`. No frameworks, no stow, no nix — clone, run one script, done. The same setup bootstraps remote machines over SSH.

> 📄 **New to this?** There's a printable [tmux + Claude Code cheat sheet](https://wusche1.github.io/dotfiles/) covering the day-to-day shortcuts.

## Setup

Install the core tools — [Ghostty](https://ghostty.org/) (terminal), tmux, zsh, and neovim — then run the installer below.

### macOS (Homebrew)

```bash
brew install --cask ghostty
brew install tmux zsh neovim
```

### Linux (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install -y tmux zsh
sudo snap install nvim --classic   # apt's neovim is usually too old for LazyVim
```

Ghostty isn't in apt — install it from the [official downloads](https://ghostty.org/download) (or your distro's package manager). On other distros, swap `apt` for your package manager (`dnf`, `pacman`, …).

### Windows

Not recommended — this setup targets macOS and Linux. If you must, use [WSL2](https://learn.microsoft.com/windows/wsl/) and follow the Linux steps inside it.

## Installation

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## How it's organized

Each tool gets its own directory holding exactly the files that tool reads. `install.sh` symlinks them to where the tool expects them in `~`, so editing a file here (or in `~`) changes both.

```
dotfiles/
├── install.sh        # Symlinks everything into place (backs up what it replaces)
├── zsh/              # .zshrc (aliases, functions) + .zshenv (PATH, secrets, direnv)
├── tmux/             # .tmux.conf — Kanagawa theme, C-Space prefix, F12 nested toggle
├── ghostty/          # Terminal config — Kanagawa Wave, Opt+hjkl splits, cursor shader
├── nvim/             # LazyVim-based neovim config
├── git/              # .gitconfig
├── claude/           # Claude Code: settings.json, rules/, skills/ → symlinked to ~/.claude
├── vscode/           # VS Code settings
├── scripts/          # tmux-worktree, setup-remote.sh, tmux session helpers, this README's cheat-sheet builder
├── secrets/          # Age-encrypted env files (decrypted on install, never committed in plaintext)
└── docs/             # The published cheat sheet (GitHub Pages)
```

The pieces are wired to reinforce each other:

- **Kanagawa theme** across Ghostty, tmux, and neovim, so every layer looks the same.
- **`C-Space` (Ctrl+Space) is the tmux prefix** on both local and remote machines; `F12` toggles the local prefix off so it passes through to a remote tmux when you SSH in.
- **Secrets are age-encrypted** in `secrets/` and decrypted by `install.sh` using your SSH key, so API keys land automatically on any machine.

## How it works

The install script creates symlinks from your home directory to this repo. Any changes you make to the dotfiles (either in `~` or in this repo) are reflected in both places.

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
