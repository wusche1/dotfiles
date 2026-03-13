# Dotfiles

Inspired by [vossenwout/pookie-dotfiles](https://github.com/vossenwout/pookie-dotfiles). The F12 nested tmux session toggle in `tmux/.tmux.conf` is taken from there.

## Structure

- `install.sh` — Symlinks everything into place. Uses a `link()` helper that backs up existing files.
- `zsh/` — `.zshrc` (aliases, functions) and `.zshenv` (PATH, secrets, direnv)
- `tmux/.tmux.conf` — Kanagawa theme, `C-Space` prefix, vim bindings, F12 nested session toggle
- `ghostty/config` — Kanagawa Wave theme, Opt+hjkl split nav, custom cursor shader
- `nvim/` — LazyVim-based neovim config
- `git/.gitconfig` — User: Julian Schulz
- `claude/` — Claude Code settings, rules, agents, skills (symlinked to `~/.claude/`)
- `scripts/` — `tmux-worktree` (git worktree + tmux window), `setup-remote.sh` (bootstraps remote dev machines)
- `secrets/` — Age-encrypted env files, not committed in plaintext

## Key patterns

- **Symlink-based install**: `install.sh` creates symlinks, no stow/nix
- **Remote dev workflow**: `remote user@host` function in `.zshrc` SSHes in, clones dotfiles, runs `setup-remote.sh` + `install.sh`, then opens tmux
- **`setup-remote.sh`**: Installs zsh, tmux, neovim, uv, direnv, node, claude-code, age on remote Linux machines (assumes apt)
- **Secrets**: Age-encrypted, decrypted by `install.sh`. Key lives at `~/.ssh/id_ed25519`
- **Nested tmux**: F12 toggles local tmux off/on for SSH into remote tmux sessions (same `C-Space` prefix on both)
- **GitHub repo**: `wusche1/dotfiles`
