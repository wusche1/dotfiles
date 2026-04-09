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

# git (need 2.31+ for diffview.nvim)
if ! git --version 2>/dev/null | grep -qE 'git version (2\.(3[1-9]|[4-9][0-9])|[3-9]\.)'; then
    echo 'Upgrading git...'
    apt-get update && apt-get install -y software-properties-common
    add-apt-repository ppa:git-core/ppa -y
    apt-get update && apt-get install -y git
fi

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
    curl -fsSL https://claude.ai/install.sh | bash
}

# GitHub CLI
command -v gh > /dev/null || {
    echo 'Installing gh...'
    (type -p wget >/dev/null || apt-get install -y wget) \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh
}

# tmux (need 3.3+ for allow-passthrough and pane-border-lines)
if ! tmux -V 2>/dev/null | awk '{if ($2 >= 3.3) exit 0; else exit 1}'; then
    echo 'Installing tmux 3.5a from source...'
    apt-get update && apt-get install -y libevent-dev ncurses-dev build-essential bison
    curl -Lo /tmp/tmux.tar.gz https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz
    cd /tmp && tar xzf tmux.tar.gz && cd tmux-3.5a
    ./configure && make -j$(nproc) && make install
    cd /tmp && rm -rf tmux-3.5a tmux.tar.gz
fi

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
