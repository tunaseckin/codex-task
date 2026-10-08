# codex-task

> **Written entirely by AI.** Every line in this repository — the script, the
> skills, this README, the commit messages — was written by Claude (Anthropic's
> Claude Code) during a working session. A human owns the account, chose to
> publish it, and lived through the incident described below, but wrote none
> of it. Read it the way you would read any code you did not write yourself.

Hand work from Claude Code to OpenAI Codex, without letting it near your
working tree.

If your Claude quota runs out before your day does, and you also pay for
ChatGPT, the second subscription is sitting idle. This is a small script and
two slash commands that let one agent do the heavy lifting while the other
keeps the context.

## Why a worktree

Codex writes well. That is the problem.

This repo exists because an agent, trying to undo its own edit, restored a
file from a two-week-old archive and silently deleted a fortnight of work:
four verified security fixes and an entire moderation layer. Nothing was in
git at the time. The work was only recovered by digging through session
transcripts.

So: Codex runs with write access, but in a **separate git worktree**. It
cannot touch your checkout. When it finishes you get a patch. Applying it is
a separate, deliberate step.

```
$ ./codex-task.sh "add an .editorconfig"
...
============================================================
Codex worked in:
  /Users/you/.codex/worktrees/9a7b/project
Your working tree was NOT touched.
============================================================

--- files ---
 .editorconfig | 14 ++++++++++++++

Apply:   git -C "..." diff --cached | git apply -
Discard: git worktree remove --force "..."
```

The script refuses to run on a dirty tree. Otherwise you cannot tell which
hunks in the returned patch are yours.

## Install

```bash
git clone https://github.com/tunaseckin/codex-task
cp codex-task.sh /path/to/your/project/
mkdir -p /path/to/your/project/.claude/skills
cp -r skills/gpt skills/claude /path/to/your/project/.claude/skills/
```

Needs: a git repository, and the Codex CLI. On macOS it ships inside the
ChatGPT desktop app and is found automatically; otherwise
`npm i -g @openai/codex`, or set `CODEX_BIN`.

## Use

```bash
./codex-task.sh --read-only "where is the rate limiting done"
./codex-task.sh "rename the foo helper to bar everywhere"
```

From inside Claude Code:

| Command | Effect |
|---|---|
| `/gpt <task>` | One shot: Codex does it, Claude relays the result |
| `/gpt` | Persistent: Claude delegates concrete work until you stop |
| `/claude` | Back to normal |

## What it is not

`/gpt` does not replace Claude with GPT. Every turn still goes through
Claude; it just stops doing the expensive part itself. If you want to spend
no Claude quota at all, run `codex-task.sh` from your terminal directly.

Codex does not see your Claude conversation. Every call starts cold. Delegate
searching, reading and mechanical edits — not decisions that depend on
context you built up over an hour.

## License

MIT
