#!/bin/bash

# Editor
alias code="open -a Cursor"

# Navigation
alias ..="cd .."
alias ...="cd ../.."

# List
alias ll="ls -lah"

# Git
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"

# Vast.ai SSH helper
vast() {
	local port="" host="" user="" args=("$@") 
	[ "${args[1]}" = "ssh" ] && args=("${args[@]:1}") 
	for ((i=1; i<=${#args[@]}; i++)) do
		[ "${args[$i]}" = "-p" ] && port="${args[$((i+1))]}" 
		[[ "${args[$i]}" =~ ^[^-].+@.+ ]] && user=$(echo "${args[$i]}" | cut -d@ -f1)  && host=$(echo "${args[$i]}" | cut -d@ -f2) 
	done
	[ -z "$host" ] && echo "Usage: vast ssh -p PORT USER@HOST [-L ...]" && return 1
	local ssh_host="${user}@${host}" 
	[ -n "$port" ] && ssh_host="${user}@${host}:${port}" 
	ssh-keyscan -p "${port:-22}" "$host" >> ~/.ssh/known_hosts 2> /dev/null
	local repo_path=$(ssh -p "${port:-22}" "${user}@${host}" "ls -1 /root/workspace 2>/dev/null | head -n1") 
	local remote_path="/root/workspace" 
	[ -n "$repo_path" ] && remote_path="/root/workspace/$repo_path" 
	cursor --remote "ssh-remote+${ssh_host}" "$remote_path"
}

