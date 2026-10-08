---
name: gpt
description: Delegate the work to OpenAI Codex instead of doing it yourself. With an argument it is one-shot; without one it turns on a persistent delegate mode. Use when the user wants to spend their OpenAI quota rather than their Claude quota.
---

# GPT mode

The user wants to preserve Claude quota. Hand the work to Codex with
`codex-task.sh` (in this repo, or wherever they installed it).

## With an argument: one shot

Run it and relay the output **as it comes back**. Do not re-analyse,
re-verify, or add commentary. The entire point is to spend as few of your own
tokens as possible.

```
./codex-task.sh --read-only "<argument>"   # inspection / research
./codex-task.sh "<argument>"               # when files must be written
```

In write mode Codex works in a separate git worktree. Show the patch to the
user and **do not apply it**. Applying is a separate decision, and theirs.

## Without an argument: persistent mode

Create `.claude/gpt-mode` and tell the user the mode is on. While it is on:

- Send every concrete task (search, analysis, research, mechanical edits)
  to Codex first
- Relay results briefly; do not add your own analysis
- Keep your prose short
- The mode ends with `/claude`

## What to delegate

Good: code search, log analysis, reading long files, independent research,
mechanical refactors.

Bad, and say so instead of delegating: deploying, writing to production,
security logic, anything where being wrong is expensive. Codex does not see
this conversation; every call starts cold.

## What this is not

`/gpt` does not turn you into GPT. Every turn still goes through you; you
are just having someone else do the heavy part. If the user believes
otherwise, correct them.
