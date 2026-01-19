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

# Symlink dotfiles into current project for easy editing
symhere() {
    ln -sf ~/dotfiles/claude .claude
    ln -sf ~/.secrets .secrets
    echo "Linked .claude and .secrets"
}

# Open VS Code to remote server with interactive folder selection
# Usage: remote user@host [-p port] [-i identity_file]
remote() {
    local user_host=""
    local port="22"
    local identity="$HOME/.ssh/id_ed25519"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p) port="$2"; shift 2 ;;
            -i) identity="$2"; shift 2 ;;
            ssh) shift ;;  # skip 'ssh' if included
            *@*) user_host="$1"; shift ;;
            *) shift ;;
        esac
    done

    if [[ -z "$user_host" ]]; then
        echo "Usage: remote user@host [-p port] [-i identity_file]"
        return 1
    fi

    echo "Connecting to $user_host:$port..."

    # Get folders in /workspace/
    local folder_list=$(ssh -p "$port" -i "$identity" "$user_host" "ls -d /workspace/*/ 2>/dev/null | xargs -n1 basename")
    local -a folders
    folders=("${(f)folder_list}")

    if [[ -z "$folder_list" ]]; then
        echo "No folders found in /workspace/"
        return 1
    fi

    local chosen_folder=""
    if [[ ${#folders[@]} -eq 1 ]]; then
        chosen_folder="${folders[1]}"
        echo "Found: $chosen_folder"
    else
        echo "Select folder:"
        for i in {1..${#folders[@]}}; do
            echo "  $i) ${folders[$i]}"
        done
        read "choice?Enter number: "
        chosen_folder="${folders[$choice]}"
    fi

    local final_path="/workspace/$chosen_folder"

    # Check if it's a worktree folder (contains "worktree" in name)
    if [[ "$chosen_folder" == *worktree* ]]; then
        local branch_list=$(ssh -p "$port" -i "$identity" "$user_host" "ls -d /workspace/$chosen_folder/*/ 2>/dev/null | xargs -n1 basename")
        local -a branches
        branches=("${(f)branch_list}")

        if [[ -z "$branch_list" ]]; then
            echo "No branches found in $chosen_folder"
            return 1
        elif [[ ${#branches[@]} -eq 1 ]]; then
            final_path="/workspace/$chosen_folder/${branches[1]}"
            echo "Found branch: ${branches[1]}"
        else
            echo "Select branch:"
            for i in {1..${#branches[@]}}; do
                echo "  $i) ${branches[$i]}"
            done
            read "choice?Enter number: "
            final_path="/workspace/$chosen_folder/${branches[$choice]}"
        fi
    fi

    # Copy SSH key for decrypting secrets (needed for dotfiles setup)
    ssh -p "$port" -i "$identity" "$user_host" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    scp -P "$port" -i "$identity" "$identity" "$user_host:~/.ssh/id_ed25519"
    ssh -p "$port" -i "$identity" "$user_host" "chmod 600 ~/.ssh/id_ed25519"

    # Run setup script on remote (installs dependencies)
    echo "Setting up remote environment..."
    scp -P "$port" -i "$identity" ~/dotfiles/scripts/setup-remote.sh "$user_host:/tmp/setup-remote.sh"
    ssh -p "$port" -i "$identity" "$user_host" "chmod +x /tmp/setup-remote.sh && /tmp/setup-remote.sh"

    # Setup dotfiles on remote if not present
    ssh -p "$port" -i "$identity" "$user_host" '
        if [ ! -f ~/dotfiles/install.sh ]; then
            git clone https://github.com/wusche1/dotfiles.git ~/dotfiles
        fi
        cd ~/dotfiles && git pull && ./install.sh
    '

    # Create/update SSH config entry
    local config_name="remote-dev"
    local host=$(echo "$user_host" | cut -d'@' -f2)
    local user=$(echo "$user_host" | cut -d'@' -f1)

    # Remove old config entry and add new one
    if [[ -f ~/.ssh/config ]]; then
        awk '/^Host remote-dev$/{skip=1; next} /^Host /{skip=0} !skip' ~/.ssh/config > ~/.ssh/config.tmp
        mv ~/.ssh/config.tmp ~/.ssh/config
    fi

    cat >> ~/.ssh/config << EOF

Host $config_name
    HostName $host
    User $user
    Port $port
    IdentityFile $identity
EOF

    echo "Opening VS Code to $final_path..."
    code --remote ssh-remote+$config_name "$final_path"
}
