#!/usr/bin/env bash
#
# review-diff.sh — print the change the review looks at, to stdout.
#
# The change is the in-scope part of `git diff HEAD` (tracked, staged and
# unstaged) plus every in-scope untracked, non-ignored file, rendered as an
# added file. "In scope" is decided by review-scope.sh — app code, with test
# code excluded — so this builder, review-stop-hook.sh, and review-loop.sh all
# agree on what "the change" is. review-loop.sh and review-stop-hook.sh both
# build the change by running THIS script, so the hash each takes of it agrees
# on what "the same change" means. Run it with the repository as the current
# directory.
#
# No side effects: it reads the working tree and the index but never stages,
# commits, or writes anything. A real git failure exits non-zero so the caller
# never treats a partial change as complete.
#
set -uo pipefail

# The shared scope filter, located by this script's own directory (pure bash, no
# external dirname). Every scope decision goes through it, so there is no second
# place that could disagree about which files are in scope.
script_dir="$(cd "${0%/*}" 2>/dev/null && pwd)"
scope_filter="${script_dir}/review-scope.sh"
[ -f "$scope_filter" ] || exit 1

tracked_tmp="$(mktemp)" || exit 1
untracked_tmp="$(mktemp)" || exit 1
trap 'rm -f "$tracked_tmp" "$untracked_tmp"' EXIT

# Tracked changes since the last commit, limited to in-scope files. Get the
# in-scope names first (through the shared filter), then diff exactly those — so
# the scope rule lives in one place, not restated as a git pathspec here. Names
# are NUL-delimited so non-ASCII, space, tab, and newline names stay exact. A git
# failure is a real error.
git diff --name-only -z HEAD | bash "$scope_filter" > "$tracked_tmp" || exit 1
tracked=()
while IFS= read -r -d '' f; do
  tracked+=("$f")
done < "$tracked_tmp"
if [ "${#tracked[@]}" -gt 0 ]; then
  git diff HEAD -- "${tracked[@]}" || exit 1
fi

# New files the change adds: untracked, not ignored, in scope. Render each as an
# addition without touching the index. git diff --no-index exits 1 when the two
# inputs differ — the normal case here; any status above 1 is a real error that
# must propagate.
git ls-files --others --exclude-standard -z | bash "$scope_filter" > "$untracked_tmp" || exit 1
status=0
while IFS= read -r -d '' f; do
  git diff --no-index -- /dev/null "$f"
  rc=$?
  [ "$rc" -le 1 ] || status="$rc"
done < "$untracked_tmp"

exit "$status"
