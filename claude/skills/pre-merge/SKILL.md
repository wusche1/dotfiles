---
name: pre-merge
description: Prepare the current branch for merging into main. Reviews diff, cleans artifacts, ensures code quality, runs tests, and commits.
allowed-tools: Bash, Read, Edit, Glob, Grep
---

Prepare this branch for merging into main.

## Steps

1. Run `git diff main...HEAD` and review every change carefully
2. Look for artifacts that should not be merged:
   - Debug prints, console.logs, commented-out code
   - TODO/FIXME/HACK comments added on this branch
   - Leftover files from failed approaches
   - Accidentally committed secrets, .env files, large binaries
3. Review code quality — clean up anything inelegant or unnecessarily complex
4. Run the project's test suite and fix any failures
5. Stage all changes and create a single clean commit summarizing what this branch does

If there are no issues found, just run the tests and commit.
