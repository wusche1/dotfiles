# Dotfiles

Personal dotfiles managed with symlinks. Forkable: nothing in the repo is tied to one person except the encrypted secrets, which you replace with your own (see [Secrets](#secrets)).

## Prerequisites

Everything is installed by the package manager; `install.sh` only creates symlinks.

### macOS (Homebrew)

```bash
brew install --cask ghostty
brew install zsh neovim age direnv uv ripgrep node gh
curl -fsSL https://herdr.dev/install.sh | sh                                                     # herdr (see below for the patched build)
brew install --cask karabiner-elements   # optional: mouse side buttons -> copy/paste (karabiner/)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"   # .zshrc sources it
curl -fsSL https://claude.ai/install.sh | bash                                                    # Claude Code
```

| Tool | Why |
|---|---|
| [Ghostty](https://ghostty.org/) | Terminal. Config in `ghostty/` |
| [herdr](https://herdr.dev/) | Workspace/agent manager (replaces tmux). Config in `herdr/` |
| zsh, [oh-my-zsh](https://ohmyz.sh/) | Shell |
| neovim 0.11+, ripgrep, a C compiler | LazyVim config in `nvim/` |
| [age](https://github.com/FiloSottile/age) | Decrypts `secrets/*.age` on install |
| [direnv](https://direnv.net/) | Hooked in `.zshenv`; per-project `.envrc` |
| [uv](https://docs.astral.sh/uv/) | Python; also runs the clipboard MCP server |
| node, [Claude Code](https://claude.ai/code), gh | AI-assisted workflow below |

### Linux (Debian/Ubuntu)

`scripts/setup-remote.sh` installs all of the above (apt, run as root). It is what the `remote` function runs on fresh machines, but it works locally too.

### Windows

Not supported. Use [WSL2](https://learn.microsoft.com/windows/wsl/) and follow the Linux steps.

## Installation

```bash
git clone <your-fork-url> ~/dotfiles
cd ~/dotfiles
./install.sh
claude mcp add --scope user clipboard -- uv run ~/.claude/clipboard-mcp.py   # once, for mcp__clipboard__copy
```

`install.sh` symlinks every config into place (existing files are backed up as `*.backup`), decrypts secrets, and writes `~/.gitconfig.local` and `~/.git-credentials` from them. Rerun it any time; it is idempotent.

## Secrets

Secrets live in `~/.secrets/*.env` (plain text, never committed) and are stored in the repo as `secrets/*.env.age`, encrypted with **age** to the SSH key `~/.ssh/id_ed25519`. `install.sh` decrypts them with the matching private key, so any machine that has your key gets your secrets. Files encrypted for someone else's key are skipped with a warning.

Setting up your own:

```bash
rm secrets/*.env.age                                   # the originals are encrypted for someone else
cp secrets/personal.env.example ~/.secrets/personal.env
cp secrets/claude.env.example ~/.secrets/claude.env
$EDITOR ~/.secrets/*.env
./secrets/encrypt.sh                                   # writes secrets/*.env.age, commit those
./install.sh
```

| File | Used for |
|---|---|
| `personal.env` | Sourced by every zsh. `GIT_NAME`/`GIT_EMAIL` become `~/.gitconfig.local`, `GITHUB_TOKEN` becomes `~/.git-credentials`, plus anything else you want in your environment (e.g. `WANDB_ENTITY`) |
| `claude.env` | Loaded by Claude Code at startup (`CLAUDE_ENV_FILE`). API keys for Claude and for MCP servers go here |

Edit a secret: change the file in `~/.secrets/`, run `secrets/encrypt.sh`, commit.

## Personalising

After forking, the only things worth changing are:

- `claude/settings.json`: `autoMode.environment` describes the original author's projects and trust boundaries. Delete it or rewrite it for yours.
- `claude/rules/`: working-style rules Claude follows in every project.
- `kinesis/`: firmware for a Kinesis Advantage360 Pro. Ignore it if you don't have one.
- `remote` clones whatever `git remote get-url origin` says in `~/dotfiles`, so your fork is used automatically.

## Structure

```
dotfiles/
├── install.sh            # Symlink installer
├── zsh/                  # .zshenv (PATH, secrets, direnv), .zshrc (aliases, remote)
├── herdr/                # config.toml, plugins/, herdr.patch + build.sh for the patched build
├── ghostty/              # Kanagawa theme, Opt+hjkl splits, cursor shader
├── nvim/                 # LazyVim
├── git/.gitconfig        # Generic; identity in ~/.gitconfig.local
├── claude/               # Claude Code settings, rules, agents, skills, clipboard MCP
├── vscode/settings.json
├── karabiner/            # Mouse back/forward buttons -> Cmd+C/Cmd+V (macOS)
├── scripts/              # herdr-worktree, setup-remote.sh
├── secrets/              # *.env.age (encrypted), *.env.example (templates), encrypt/decrypt
└── kinesis/              # Advantage360 Pro ZMK keymap; `make` builds firmware via Docker
```

## Workflow

The goal is maximally parallelized Claude Code integration — working on many things at once, easily switching between them, with full file visibility via neovim while Claude does its thing without interference.

### Tools

- **[Ghostty](https://ghostty.org/)** as the terminal
- **[herdr](https://herdr.dev/)** for workspaces, tabs, panes and agent status, locally and on remote machines
- **neovim** (LazyVim) for viewing and editing files
- **Claude Code** (`cc`) for AI-assisted development

Vim-style `hjkl` navigation works at every layer: Ghostty splits (`Opt+hjkl`), herdr panes (`Ctrl+hjkl`), and neovim. The herdr prefix is `Ctrl+Space`; `prefix+?` lists every binding.

### One project = one herdr workspace

Each project (repo) is a workspace in the sidebar. `prefix+shift+s` creates one in `~/Projects` (`/workspace` on remotes). `prefix+w` opens the workspace picker (`j`/`k` to move, `l` or Enter to open), `prefix+shift+1..9` jumps directly.

### One feature = one worktree + one tab

Within a project, each feature gets its own git branch **and** its own [git worktree](https://git-scm.com/docs/git-worktree), so you never need to stash or switch branches. Press `prefix+shift+w`, enter a branch name, and `scripts/herdr-worktree` creates the branch and a checkout in `<repo>_worktree/<branch>` next to the repo, then opens it in a new tab. The `.venv` from the main repo is symlinked into each worktree so you don't reinstall dependencies.

This clean separation — every issue on its own branch in its own directory — means you can run Claude Code independently in each tab without any interference between tasks. `prefix+a` / `prefix+shift+a` cycle through agents across all workspaces; `prefix+ctrl+1..9` focuses one.

### Remote development

For work that's better done on a remote machine (e.g. GPU training on RunPod), provision it once:

```bash
remote root@213.192.2.99 -p 40110 -i ~/.ssh/id_ed25519   # or: remote <ssh-config alias>
```

The `remote` function writes an ssh-config alias (`remote-<port>`) if you gave it `user@host`, copies your SSH key and Claude Code credentials, clones your dotfiles on the remote, runs `setup-remote.sh` + `install.sh`, and finally `herdr machine add`. The machine then appears in the local herdr sidebar: its workspaces and agents sit next to your local ones, with the same keybindings and the same worktree workflow. Remotes run stock herdr, so the two patched features below are local-only.

### Patched herdr

The local build carries two small patches on top of upstream (`herdr/herdr.patch`): an `index` sidebar token that numbers workspaces/agents across machines, and a `keys.navigate_workspace_select` binding so `l` opens a workspace in the picker. Stock herdr ignores both config keys with a diagnostic, so the config still loads without the patch.

```bash
./herdr/build.sh         # clone herdr to ~/Projects/cloned_repos/herdr, apply the patch, cargo build, link ~/.local/bin/herdr
./herdr/build.sh patch   # after editing the clone: regenerate herdr.patch (diff against the base commit in build.sh)
herdr server live-handoff --import-exe ~/.local/bin/herdr   # swap the running server to the new binary without losing panes
```

Needs a Rust toolchain. Bump `base` in `build.sh` to move to a newer upstream commit.

### Claude Code

Run Claude Code with `cc`. For autonomous operation, `ccdsp` starts Claude with all tool permissions auto-allowed (a workaround for remote machines where `--dangerously-skip-permissions` requires root privileges that aren't available on e.g. RunPod).

Secrets are age-encrypted in the repo and decrypted on install using your SSH key, so Claude Code gets its API keys automatically on any machine after running `install.sh`.

## Kinesis Advantage360 Pro

`kinesis/` holds the ZMK keymap (stock Kinesis layout plus: macro 1 = F12, macro 3/4 = Cmd+C/Cmd+V, backlight idle timeout 5 min). Build with Docker running:

```bash
cd kinesis && make        # produces firmware/left.uf2 and firmware/right.uf2
```

Flash each half over USB-C with a data cable: hold Mod and press macro 1 (left) or macro 3 (right), the half lights up green and mounts as `ADV360PRO`, copy the matching `.uf2` onto it. Flash the left half first, power-cycle both, then the right half with the left switched on.
