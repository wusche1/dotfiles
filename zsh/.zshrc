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

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -lah"

# Direnv
eval "$(direnv hook zsh)"

# Secrets
[ -f ~/.secrets/personal.env ] && source ~/.secrets/personal.env
export CLAUDE_ENV_FILE=~/.secrets/claude.env

# Personal config
export WANDB_ENTITY="wuschelschulz8"
