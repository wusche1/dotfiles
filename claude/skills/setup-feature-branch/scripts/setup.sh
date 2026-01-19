#!/bin/bash

set -e

BRANCH_NAME="$1"
SOURCE_BRANCH="${2:-$(git branch --show-current)}"

if [ -z "$BRANCH_NAME" ]; then
    echo "Usage: setup.sh <branch-name> [source-branch]"
    exit 1
fi

# Get repo info
REPO_ROOT="$(git rev-parse --show-toplevel)"
PARENT_DIR="$(dirname "$REPO_ROOT")"
WORKTREE_PATH="${PARENT_DIR}/${BRANCH_NAME}"

# Create the branch and worktree as sibling
git branch "$BRANCH_NAME" "$SOURCE_BRANCH" 2>/dev/null || true
git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"

# Symlink .venv if it exists (gitignored, so not in worktree by default)
if [ -d "${REPO_ROOT}/.venv" ]; then
    ln -s "${REPO_ROOT}/.venv" "${WORKTREE_PATH}/.venv"
    echo "Linked .venv"
fi

echo ""
echo "Worktree ready at: $WORKTREE_PATH"
echo "cd $WORKTREE_PATH"
