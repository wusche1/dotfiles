# Sourced by ALL zsh invocations (interactive and non-interactive)
# Keep this minimal - only PATH and essential environment variables

# Homebrew (macOS only)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Secrets
[ -f ~/.secrets/personal.env ] && source ~/.secrets/personal.env
export CLAUDE_ENV_FILE=~/.secrets/claude.env

export EDITOR=nvim
export VISUAL=nvim

# Direnv
eval "$(direnv hook zsh)"

# Environment
export PATH="$HOME/.local/bin:$PATH"
if [ -f "$HOME/.cargo/env" ]; then . "$HOME/.cargo/env"; fi

# Remote machines: keep caches off the small root overlay
if [ -d /workspace ]; then
    export UV_CACHE_DIR=/workspace/.cache/uv
    export HF_HOME=/workspace/.cache/huggingface
fi
