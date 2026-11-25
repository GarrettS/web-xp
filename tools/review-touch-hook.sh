#!/usr/bin/env bash
#
# review-touch-hook.sh — Claude Code PostToolUse hook.
#
# After each file edit, it records which worktree this session is editing, so
# the Stop hook can review THAT worktree and not another agent's. The record is
# one file per session id (session-scoped). It is never a single shared file:
# two agents editing two worktrees at once each write their own slot, so they
# cannot clobber each other.
#
# This does not tie a worktree to a session. The worktree's review state lives
# in the worktree's own git dir. This file only answers "where is session X
# editing right now", which the Stop hook needs to pick the right worktree.
#
# Fail-safe: on any missing field or error it records nothing and exits 0. It
# never blocks a tool.
#
set -uo pipefail

# jq parses the hook input; without it there is nothing to do.
command -v jq >/dev/null 2>&1 || exit 0

input="$(cat 2>/dev/null || true)"
[ -n "$input" ] || exit 0

session="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null || true)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null || true)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null || true)"

[ -n "$session" ] || exit 0
[ -n "$file" ] || exit 0

# Only the file-editing tools carry a path worth recording.
case "$tool" in
  Edit|Write|MultiEdit|NotebookEdit) ;;
  *) exit 0 ;;
esac

state_dir="${WEB_XP_STATE_DIR:-$HOME/.web-xp/state}"
record="${state_dir}/${session}.wt"

# Fast path, so the common edit stays cheap. If the edited file is already under
# the worktree recorded for this session, the record is current: no git call, no
# write. Only an edit in a different worktree does the full work below. The
# quoting keeps the recorded path literal in the pattern; the trailing /* is the
# only wildcard.
prev="$(cat "$record" 2>/dev/null || true)"
if [ -n "$prev" ]; then
  case "$file" in
    "$prev"/*) exit 0 ;;
  esac
fi

# The worktree that holds the edited file. dirname first, because the path is a
# file, not a directory. If it is not inside a git worktree, record nothing.
dir="$(cd "$(dirname "$file")" 2>/dev/null && pwd)" || exit 0
wt="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$wt" ] || exit 0

# Per-session record, named by session id so concurrent sessions never share a
# slot. Rewritten only when the session's worktree changes.
mkdir -p "$state_dir" 2>/dev/null || exit 0
printf '%s\n' "$wt" > "$record" 2>/dev/null || true

exit 0
