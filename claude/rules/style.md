# Coding Style

## Minimalism First
- Write minimal code with as few lines and moving parts as possible
- No bloated implementations
- If unsure, make your best guess or ask - don't write defensive code to handle multiple possibilities
- Prefer imports from common libraries over hand-rolling utilities

## Avoid Speculative Error Handling
Don't wrap code in try/except blocks to handle hypothetical edge cases. If a config key might be named "hf" or "huggingface", ask which one it is rather than writing fallback chains.

## Only Add If Explicitly Asked
- Docstrings
- Error catching/handling
- Comments
- README files or edits
- Git commits
