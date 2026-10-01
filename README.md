# Dotfiles (minimal)

A small terminal setup for running [Claude Code](https://claude.ai/code) on many things at once: [herdr](https://herdr.dev/) keeps one workspace per project and one tab per branch, each with its own Claude, and neovim shows you the files. The keybinding handout is in `docs/index.html` (open it in a browser, prints to one A4 page).

This is the `minimal` branch: no secrets, no hardware, nothing personal. The `master` branch is the full version.

## Install

macOS:

```bash
brew install --cask ghostty
brew install zsh neovim direnv uv ripgrep node gh
curl -fsSL https://herdr.dev/install.sh | sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"   # .zshrc sources it
curl -fsSL https://claude.ai/install.sh | bash
```

Linux (Debian/Ubuntu): `sudo scripts/setup-remote.sh` installs the same tools (no Ghostty; any terminal with 24-bit color works).

Then:

```bash
git clone -b minimal https://github.com/wusche1/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
printf '[user]\n\tname = Your Name\n\temail = you@example.com\n' > ~/.gitconfig.local
claude mcp add --scope user clipboard -- uv run ~/.claude/clipboard-mcp.py   # optional: lets Claude put text on your clipboard
```

`install.sh` symlinks every config into place (existing files are backed up as `*.backup`). Rerun it any time.

## Use

```bash
herdr      # opens your workspaces; everything keeps running when you close the terminal
claude     # or `cc`
```

The prefix is `Ctrl+Space`, then a key; `Ctrl+Space ?` lists everything. The ones that matter:

| Keys | What |
|---|---|
| `Ctrl+Space Shift+S` | New workspace (= project) in `~/Projects` |
| `Ctrl+Space w` | Workspace picker (`j`/`k`, Enter) |
| `Ctrl+Space Shift+W` | New branch + git worktree, opened in a new tab |
| `Ctrl+Space v` / `s` | Split the pane left/right or top/bottom |
| `Ctrl+h j k l` | Move between panes |
| `Ctrl+Space a` | Jump to the next Claude agent that needs you |
| `Ctrl+Space q` | Detach; `herdr` brings it all back |

The full handout with the mental model (workspace = project, tab = branch, pane = agent vs. your eyes) is `docs/index.html`.

## What's in here

```
dotfiles/
├── install.sh         # Symlink installer
├── zsh/               # .zshenv (PATH, direnv), .zshrc (oh-my-zsh, aliases)
├── herdr/             # config.toml (Kanagawa, Ctrl+Space prefix, vim keys), new-workspace plugin
├── ghostty/           # Kanagawa theme, Opt+hjkl splits
├── nvim/              # LazyVim
├── git/.gitconfig     # Includes ~/.gitconfig.local for your identity
├── claude/            # Claude Code settings, rules (coding style), clipboard MCP
├── scripts/           # herdr-worktree (Ctrl+Space Shift+W), setup-remote.sh, build-cheatsheet.py
└── docs/              # The keybinding handout (cheatsheet.yaml -> index.html)
```

`claude/rules/` holds the working-style rules Claude follows in every project — edit them to taste. `claude/settings.json` sets `defaultMode: auto`; change it if you'd rather approve every tool call.
