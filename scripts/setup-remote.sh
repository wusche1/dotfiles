#!/bin/bash
echo '=== Checking environment ==='

# age (for secrets decryption)
command -v age > /dev/null || {
    echo 'Installing age...'
    curl -Lo /tmp/age.tar.gz https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-linux-amd64.tar.gz
    tar xf /tmp/age.tar.gz -C /tmp
    mv /tmp/age/age /tmp/age/age-keygen /usr/local/bin/
    rm -rf /tmp/age /tmp/age.tar.gz
}

# direnv
command -v direnv > /dev/null || {
    echo 'Installing direnv...'
    apt-get update && apt-get install -y direnv
}

# uv
command -v uv > /dev/null || {
    echo 'Installing uv...'
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

# zsh
command -v zsh > /dev/null || {
    echo 'Installing zsh...'
    apt-get update && apt-get install -y zsh
}
# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo 'Setting zsh as default shell...'
    chsh -s $(which zsh)
fi

# Node.js and npm
command -v npm > /dev/null || {
    echo 'Installing Node.js...'
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
}

# Claude Code CLI
command -v claude > /dev/null || {
    echo 'Installing Claude Code...'
    curl -fsSL https://cli.claude.ai/install.sh | sh
}

# tmux
command -v tmux > /dev/null || {
    echo 'Installing tmux...'
    apt-get update && apt-get install -y tmux
}

# neovim (smart install - try prebuilt, build from source if needed)
if ! command -v nvim > /dev/null || ! nvim --version 2>/dev/null | grep -q "v0.11"; then
    echo 'Installing neovim...'

    # Try latest prebuilt binary first
    echo 'Trying latest prebuilt binary...'
    curl -Lo /tmp/nvim.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz 2>/dev/null
    if [ -f /tmp/nvim.tar.gz ]; then
        tar xzf /tmp/nvim.tar.gz -C /tmp 2>/dev/null
        if [ -d /tmp/nvim-linux-x86_64 ]; then
            rm -rf /opt/nvim
            mv /tmp/nvim-linux-x86_64 /opt/nvim
            ln -sf /opt/nvim/bin/nvim /usr/bin/nvim
            rm /tmp/nvim.tar.gz
        fi
    fi

    # Check if prebuilt binary works (might fail due to glibc)
    if ! nvim --version 2>/dev/null | grep -q "v0.11"; then
        echo 'Prebuilt binary failed (likely old glibc), building from source...'
        apt-get update && apt-get install -y ninja-build gettext cmake unzip curl build-essential git

        cd /tmp
        rm -rf neovim
        git clone https://github.com/neovim/neovim
        cd neovim
        git checkout stable
        make CMAKE_BUILD_TYPE=Release
        make install
        cd /tmp
        rm -rf neovim
    fi
fi

# C compiler (required for nvim-treesitter parser compilation)
command -v gcc > /dev/null || {
    echo 'Installing build-essential for treesitter...'
    apt-get update && apt-get install -y build-essential
}

# LazyVim bootstrap: nuke stale plugin cache and sync fresh
echo 'Syncing LazyVim plugins...'
rm -rf ~/.local/share/nvim/lazy ~/.local/state/nvim/lazy ~/.cache/nvim
nvim --headless "+Lazy! sync" +qa 2>/dev/null

# Ghostty terminfo (for Ghostty terminal support)
if [ ! -f ~/.terminfo/x/xterm-ghostty ]; then
    echo 'Installing Ghostty terminfo...'
    mkdir -p ~/.terminfo
    echo 'xterm-ghostty|Ghostty terminal emulator,
	use=xterm-256color,' > /tmp/xterm-ghostty.terminfo
    tic -x -o ~/.terminfo /tmp/xterm-ghostty.terminfo 2>/dev/null || true
    rm -f /tmp/xterm-ghostty.terminfo
fi


echo '=== Environment ready ==='
