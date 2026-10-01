# Sourced only for interactive shells
# Environment variables and PATH are in .zshenv

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Git
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gd="git diff"
alias gl="git log --oneline --graph"

# Claude Code
alias cc="claude"
alias ccdsp="IS_SANDBOX=1 claude --permission-mode bypassPermissions"
alias ccnight="claude --permission-mode auto --disallowedTools AskUserQuestion"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -lah"

# Symlink dotfiles into current project for easy editing
symhere() {
    ln -sf ~/dotfiles/claude .claude
    ln -sf ~/.secrets .secrets
    echo "Linked .claude and .secrets"
}

# Provision a remote machine and save it as a herdr machine (shows up in the sidebar)
# Usage: remote ssh-alias | remote user@host [-p port] [-i identity_file]
remote() {
    local user_host="" port="22" identity="$HOME/.ssh/id_ed25519"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p) port="$2"; shift 2 ;;
            -i) identity="$2"; shift 2 ;;
            ssh) shift ;;  # skip 'ssh' if included
            *) user_host="$1"; shift ;;
        esac
    done
    if [[ -z "$user_host" ]]; then
        echo "Usage: remote ssh-alias | remote user@host [-p port] [-i identity_file]"
        return 1
    fi

    # herdr machines are ssh-config aliases; turn user@host into one
    local host="$user_host"
    if [[ "$user_host" == *@* ]]; then
        host="remote-$port"
        printf '\nHost %s\n    HostName %s\n    User %s\n    Port %s\n    IdentityFile %s\n' \
            "$host" "${user_host#*@}" "${user_host%@*}" "$port" "$identity" >> ~/.ssh/config
    fi
    local ssh_opts=(-o ServerAliveInterval=60 -o ServerAliveCountMax=3)

    # SSH key for decrypting secrets on the remote
    ssh "${ssh_opts[@]}" "$host" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    scp "$identity" "$host:~/.ssh/id_ed25519"
    ssh "${ssh_opts[@]}" "$host" "chmod 600 ~/.ssh/id_ed25519"

    # Claude Code subscription credentials from macOS Keychain
    local claude_creds=$(security find-generic-password -s "Claude Code-credentials" -w)
    if [[ -z "$claude_creds" ]]; then
        echo "ERROR: could not read Claude Code credentials from Keychain"
        return 1
    fi
    echo "$claude_creds" | \
        ssh "${ssh_opts[@]}" "$host" 'mkdir -p ~/.claude && cat > ~/.claude/.credentials.json && chmod 600 ~/.claude/.credentials.json'

    echo "Setting up remote environment..."
    local repo=$(git -C ~/dotfiles remote get-url origin)
    ssh "${ssh_opts[@]}" "$host" "
        if [ ! -d ~/dotfiles ]; then
            git clone $repo ~/dotfiles
        else
            cd ~/dotfiles && git pull
        fi
        ~/dotfiles/scripts/setup-remote.sh
        cd ~/dotfiles && ./install.sh
        echo 'Syncing neovim plugins...'
        nvim --headless '+Lazy! sync' +qa > /dev/null 2>&1
    "

    herdr machine add --label "$host" "$host"
}

# Run python script with nohup, auto-naming output from config
run() {
    local config="$1"
    local name=$(basename "$config" .yaml)
    nohup uv run python main.py -c "$config" > "${name}.out" 2>&1 &
    echo "Started PID $! → ${name}.out"
}
export PATH="/opt/homebrew/bin:$PATH"

# Auto-activate .venv: check cwd first, then walk up to find one
activate_venv() {
    [[ -n "$VIRTUAL_ENV" ]] && return
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.venv/bin/activate" ]]; then
            source "$dir/.venv/bin/activate"
            return
        fi
        dir="$(dirname "$dir")"
    done
}
activate_venv
