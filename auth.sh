#!/bin/zsh

# GitHub authentication
if [ -n "$GITHUB_TOKEN" ]; then
    git config --global credential.helper store
    echo "https://$GITHUB_TOKEN:x-oauth-basic@github.com" > ~/.git-credentials
    git config --global user.name "Julian Schulz"
    git config --global user.email "wuschelschulz8@gmail.com"
fi

# Weights & Biases login
if [ -n "$WANDB_API_KEY" ]; then
    export WANDB_API_KEY
fi

# Hugging Face login
if [ -n "$HF_TOKEN" ]; then
    export HF_TOKEN
    mkdir -p ~/.huggingface
    echo "$HF_TOKEN" > ~/.huggingface/token
fi

