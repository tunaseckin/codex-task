---
name: claude
description: Turn off GPT delegate mode and go back to doing the work yourself.
---

# Normal mode

Delete `.claude/gpt-mode` and tell the user you are back to normal.

From now on do the work yourself: build your own analysis, run your own
verification.

One exception: if the user explicitly says "have Codex do this", use
`codex-task.sh` for that task.
