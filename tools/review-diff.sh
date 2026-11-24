#!/usr/bin/env bash
#
# review-diff.sh — print the change the review looks at, to stdout.
#
# The change is `git diff HEAD` (tracked, staged and unstaged) plus every
# untracked, non-ignored code file, rendered as an added file. review-loop.sh
# and review-stop-hook.sh both build the change by running THIS script, so the
# hash each takes of it agrees on what "the same change" means. Run it with the
# repository as the current directory.
#
# No side effects: it reads the working tree and the index but never stages,
# commits, or writes anything. A real git failure exits non-zero so the caller
# never treats a partial change as complete.
#
set -uo pipefail
shopt -s nocasematch

tmp_untracked="$(mktemp)" || exit 1
trap 'rm -f "$tmp_untracked"' EXIT

# Tracked changes since the last commit. A git failure here is a real error.
git diff HEAD || exit 1

# New files the change adds: untracked, not ignored, code only. List them
# NUL-delimited so non-ASCII, space, tab, and newline names stay exact (git
# otherwise quotes them, and the extension match would miss them). Render each
# as an addition without touching the index. git diff --no-index exits 1 when
# the two inputs differ — the normal case here; any status above 1 is a real
# error that must propagate.
git ls-files --others --exclude-standard -z > "$tmp_untracked" || exit 1
status=0
while IFS= read -r -d '' f; do
  case "$f" in
    *.js|*.mjs|*.ts|*.html|*.css) ;;
    *) continue ;;
  esac
  git diff --no-index -- /dev/null "$f"
  rc=$?
  [ "$rc" -le 1 ] || status="$rc"
done < "$tmp_untracked"

exit "$status"
