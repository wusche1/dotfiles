# Dotfiles

Inspired by [vossenwout/pookie-dotfiles](https://github.com/vossenwout/pookie-dotfiles).

## Structure

- `install.sh` — Symlinks everything into place. Uses a `link()` helper that backs up existing files.
- `zsh/` — `.zshrc` (aliases, functions) and `.zshenv` (PATH, secrets, direnv)
- `herdr/` — `config.toml` (Kanagawa, `C-Space` prefix, vim bindings), `plugins/`, `herdr.patch` + `build.sh` for the locally patched build
- `ghostty/config` — Kanagawa Wave theme, Opt+hjkl split nav, custom cursor shader
- `nvim/` — LazyVim-based neovim config
- `git/.gitconfig` — Generic; identity comes from `~/.gitconfig.local`, written by `install.sh` from `GIT_NAME`/`GIT_EMAIL` in secrets
- `claude/` — Claude Code settings, rules, agents, skills (symlinked to `~/.claude/`)
- `scripts/` — `herdr-worktree` (prompt + git worktree + herdr tab, run from a herdr popup), `setup-remote.sh` (bootstraps remote dev machines)
- `secrets/` — Age-encrypted env files, not committed in plaintext

## Key patterns

- **Symlink-based install**: `install.sh` creates symlinks, no stow/nix
- **Remote dev workflow**: `remote user@host|alias` function in `.zshrc` writes an ssh-config alias, copies key + Claude creds, clones dotfiles, runs `setup-remote.sh` + `install.sh`, then `herdr machine add`
- **`setup-remote.sh`**: Installs zsh, herdr, neovim, uv, direnv, node, claude-code, age on remote Linux machines (assumes apt)
- **Patched herdr**: `~/.local/bin/herdr` is built from `herdr/herdr.patch` via `herdr/build.sh`; stock herdr (remotes) ignores the extra config keys. After editing the clone, `./herdr/build.sh patch`
- **Secrets**: Age-encrypted, decrypted by `install.sh`. Key lives at `~/.ssh/id_ed25519`
- **Clipboard**: `claude/clipboard-mcp.py` provides `mcp__clipboard__copy`. Use it whenever you produce text Julian likely wants to copy (paths, snippets, commands, generated content) — it shows its own consent dialog, so call it directly.
- **GitHub repo**: `wusche1/dotfiles`
