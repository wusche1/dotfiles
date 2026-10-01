# Dotfiles (minimal branch)

Inspired by [vossenwout/pookie-dotfiles](https://github.com/vossenwout/pookie-dotfiles). This branch is the stripped-down teaching version of `master`: no secrets, no herdr patch, no hardware configs.

## Structure

- `install.sh` — Symlinks everything into place. Uses a `link()` helper that backs up existing files.
- `zsh/` — `.zshrc` (aliases) and `.zshenv` (PATH, direnv)
- `herdr/` — `config.toml` (Kanagawa, `C-Space` prefix, vim bindings), `plugins/new-workspace`
- `ghostty/config` — Kanagawa Wave theme, Opt+hjkl split nav, custom cursor shader
- `nvim/` — LazyVim-based neovim config
- `git/.gitconfig` — Only includes `~/.gitconfig.local`, which the user writes by hand
- `claude/` — Claude Code settings, rules, skills (symlinked to `~/.claude/`)
- `scripts/` — `herdr-worktree` (prompt + git worktree + herdr tab, run from a herdr popup), `setup-remote.sh` (installs the toolchain on Debian/Ubuntu), `build-cheatsheet.py` (docs/cheatsheet.yaml → docs/index.html)
- `docs/` — the keybinding handout

## Key patterns

- **Symlink-based install**: `install.sh` creates symlinks, no stow/nix
- **Clipboard**: `claude/clipboard-mcp.py` provides `mcp__clipboard__copy`. Use it whenever you produce text the user likely wants to copy (paths, snippets, commands, generated content) — it shows its own consent dialog, so call it directly.
- **GitHub repo**: `wusche1/dotfiles`, branch `minimal`
