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
alias ccdsp="claude --dangerously-skip-permissions"

# Tmux
alias tmux="TERM=xterm-256color tmux"

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

    # Setup dotfiles and run setup script on remote
    echo "Setting up remote environment..."
    ssh -p "$port" -i "$identity" "$user_host" '
        if [ ! -d ~/dotfiles ]; then
            git clone https://github.com/wusche1/dotfiles.git ~/dotfiles
        else
            cd ~/dotfiles && git pull
        fi
        ~/dotfiles/scripts/setup-remote.sh
        cd ~/dotfiles && ./install.sh
    '

    # SSH into remote and start/attach tmux session
    local session_name=$(basename "$final_path" | tr '.' '_' | tr '-' '_')
    echo "Connecting to $final_path (tmux session: $session_name)..."
    ssh -p "$port" -i "$identity" "$user_host" -t "cd $final_path && (tmux attach -t $session_name 2>/dev/null || tmux new -s $session_name)"
}

# Run python script with nohup, auto-naming output from config
run() {
    local config="$1"
    local name=$(basename "$config" .yaml)
    nohup python main.py -c "$config" > "${name}.out" 2>&1 &
    echo "Started PID $! → ${name}.out"
}
export PATH="/opt/homebrew/bin:$PATH"
