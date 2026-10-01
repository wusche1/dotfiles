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
