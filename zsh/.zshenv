# Sourced by ALL zsh invocations (interactive and non-interactive)
# Keep this minimal - only PATH and essential environment variables

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Secrets
[ -f ~/.secrets/personal.env ] && source ~/.secrets/personal.env
export CLAUDE_ENV_FILE=~/.secrets/claude.env

# Personal config
export WANDB_ENTITY="wuschelschulz8"

# Direnv
eval "$(direnv hook zsh)"

# Environment
. "$HOME/.local/bin/env"
