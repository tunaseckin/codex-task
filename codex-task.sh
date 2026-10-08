#!/usr/bin/env bash
# Delegate a task to OpenAI Codex from inside another agent's session.
#
# Codex runs in a SEPARATE git worktree, so it cannot touch your working
# tree. When it finishes you get a patch to review. Applying it is a
# separate, deliberate step.
#
#   codex-task.sh "refactor the parser"     # write mode (isolated worktree)
#   codex-task.sh --read-only "where is X"  # inspect only, no writes
set -euo pipefail

usage() { echo "usage: $(basename "$0") [--read-only] \"task\"" >&2; exit 1; }

MODE="workspace-write"
if [ "${1:-}" = "--read-only" ] || [ "${1:-}" = "--oku" ]; then MODE="read-only"; shift; fi
[ $# -ge 1 ] || usage

# Codex ships inside the ChatGPT desktop app on macOS; also honour $PATH
# and an explicit override.
CODEX="${CODEX_BIN:-}"
if [ -z "$CODEX" ]; then
  if command -v codex >/dev/null 2>&1; then
    CODEX="$(command -v codex)"
  elif [ -x "/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex" ]; then
    CODEX="/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex"
  fi
fi
[ -n "$CODEX" ] && [ -x "$CODEX" ] || {
  echo "codex not found. Install the CLI (npm i -g @openai/codex) or the" >&2
  echo "ChatGPT desktop app, or set CODEX_BIN=/path/to/codex." >&2
  exit 1
}

git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repository" >&2; exit 1; }

if [ "$MODE" = "read-only" ]; then
  exec "$CODEX" exec --sandbox read-only --skip-git-repo-check "$1" < /dev/null
fi

# A dirty tree makes the returned patch impossible to read: you cannot tell
# which hunks are yours and which are Codex's.
if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is dirty. Commit or stash first, then delegate." >&2
  git status --short >&2
  exit 1
fi

BEFORE=$(mktemp); git worktree list --porcelain | grep '^worktree ' | sort > "$BEFORE"
"$CODEX" exec --worktree --sandbox workspace-write "$1" < /dev/null
AFTER=$(mktemp); git worktree list --porcelain | grep '^worktree ' | sort > "$AFTER"
NEW=$(comm -13 "$BEFORE" "$AFTER" | sed 's/^worktree //' | tail -1)
rm -f "$BEFORE" "$AFTER"

[ -n "$NEW" ] || { echo; echo "No new worktree: Codex wrote nothing."; exit 0; }

echo
echo "============================================================"
echo "Codex worked in:"
echo "  $NEW"
echo "Your working tree was NOT touched."
echo "============================================================"
echo

git -C "$NEW" add -A >/dev/null 2>&1 || true
if git -C "$NEW" diff --cached --quiet; then
  echo "No changes."
else
  echo "--- files ---"
  git -C "$NEW" diff --cached --stat
  echo
  echo "--- patch ---"
  git -C "$NEW" diff --cached
  echo
  echo "Apply:   git -C \"$NEW\" diff --cached | git apply -"
  echo "Discard: git worktree remove --force \"$NEW\""
fi
