---
name: setup-feature-branch
description: Creates an isolated git worktree for feature development. Use when starting work on a new feature branch.
allowed-tools: Bash
---

# Setup Feature Branch

Creates a new git worktree as a sibling folder for isolated feature development.

## Usage

```bash
~/.claude/skills/setup-feature-branch/scripts/setup.sh <branch-name> [source-branch]
```

Arguments:
- `branch-name`: Name for the feature branch (e.g., `feature-auth`)
- `source-branch`: Optional. Branch to branch from (default: current branch)

## What it does

1. Creates a new git branch from the source branch
2. Creates a worktree as sibling: `../<branch-name>/`
3. Symlinks `.venv` from the main repo if it exists

## Structure

All branches live as siblings:
```
/workspace/
├── main/           # main branch (original clone)
├── feature-a/      # worktree
└── feature-b/      # worktree
```

## Output

The script outputs the worktree path. Use that path for all subsequent work.
