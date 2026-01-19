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

# Node.js and npm
command -v npm > /dev/null || {
    echo 'Installing Node.js...'
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
}

# Claude Code CLI
command -v claude > /dev/null || {
    echo 'Installing Claude Code...'
    npm install -g @anthropic-ai/claude-code
}

echo '=== Environment ready ==='
