#!/usr/bin/env bash
#
# review-stop-hook.sh — Claude Code Stop hook for the Web XP Review Workflow Loop.
#
# This hook does NOT run Codex. It is a gate. When Claude tries to finish a turn
# with uncommitted code changes — tracked or new — it checks whether Codex has
# given those exact changes a clean review (recorded by code-loop.sh in the
# git dir). If not, it blocks the stop and tells Claude to run the review loop
# itself and summarize the result — so the handoff, Codex's response, and
# Claude's fixes all happen visibly in the conversation instead of silently
# inside this hook.
#
# Fail-safe: on any error it cannot resolve — missing tools, an unbuildable
# change, state it cannot persist — it stays silent and ALLOWS the stop rather
# than trapping the turn.
#
# Claude can leave the loop three ways:
#   - a clean Codex review of the current changes (the hook allows the stop);
#   - stopping to ask the user about a finding whose answer depends on the
#     use-case (Claude creates the ask-user marker and the hook lets it pause);
#   - a block cap, so an unfixable or contested finding cannot trap it.
#
set -uo pipefail

# Sibling scripts, located by this script's own directory (pure bash, no external
# `dirname`): the change-set builder (review-diff.sh) and the scope filter
# (review-scope.sh). code-loop.sh uses the same two, so the hash here matches
# the one it recorded and the two agree on which files are in scope.
script_dir="$(cd "${0%/*}" 2>/dev/null && pwd)"
diff_builder="${script_dir}/review-diff.sh"
scope_filter="${script_dir}/review-scope.sh"

# Stop-hook input arrives as JSON on stdin; we need the project cwd.
input="$(cat 2>/dev/null || true)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -n "$cwd" ] || cwd="$PWD"
cd "$cwd" 2>/dev/null || exit 0

# --- gates: stay silent (allow the stop) unless everything lines up ---
[ -f AGENTS.md ] || [ -f CLAUDE.md ] || [ -f CODEX.md ] || exit 0
command -v codex >/dev/null 2>&1 && command -v jq >/dev/null 2>&1 || exit 0
[ -f "$HOME/.web-xp/code-guidelines.md" ] || exit 0
[ -f "$diff_builder" ] || exit 0
[ -f "$scope_filter" ] || exit 0
if [ -f prd/project.md ] && grep -iqE 'review-loop:[[:space:]]*off' prd/project.md; then exit 0; fi

# Any in-scope app-code change to review — tracked or new, test code excluded by
# the shared scope filter? Build the list through it (the same filter the loop
# uses) into a temp file so a git failure is not read as "no changes". If the
# list is empty there is nothing to gate on.
changes_tmp="$(mktemp 2>/dev/null)" || exit 0
{ git diff --name-only -z HEAD 2>/dev/null; git ls-files --others --exclude-standard -z 2>/dev/null; } \
  | bash "$scope_filter" > "$changes_tmp" 2>/dev/null
have_code=0
[ -s "$changes_tmp" ] && have_code=1
rm -f "$changes_tmp" 2>/dev/null
[ "$have_code" -eq 1 ] || exit 0

gitdir="$(git rev-parse --git-dir 2>/dev/null || echo .git)"
round_file="${gitdir}/.web-xp-review-round"
hash_file="${gitdir}/.web-xp-review-hash"
findings_file="${gitdir}/.web-xp-review-findings"
blocks_file="${gitdir}/.web-xp-review-blocks"
resp_file="${gitdir}/.web-xp-review-responses.md"
ask_marker="${gitdir}/.web-xp-review-ask-user"

clear_state() { rm -f "$round_file" "$hash_file" "$findings_file" "$blocks_file" "$resp_file" 2>/dev/null; }

# Claude is deferring a finding to the user. Let it pause, once per marker.
if [ -f "$ask_marker" ]; then rm -f "$ask_marker" 2>/dev/null; exit 0; fi

# The change Codex would review right now — built exactly as code-loop.sh does
# (git diff HEAD plus untracked new code files), via review-diff.sh, and hashed
# the same way (raw bytes). On any build or hash error, stay silent (allow).
current_hash="$(bash "$diff_builder" 2>/dev/null | git hash-object --no-filters --stdin 2>/dev/null)"
cs_rc=$?
[ "$cs_rc" -eq 0 ] && [ -n "$current_hash" ] || exit 0

reviewed_hash="$(cat "$hash_file" 2>/dev/null || echo none)"
findings="$(cat "$findings_file" 2>/dev/null || echo -1)"
round="$(cat "$round_file" 2>/dev/null || echo 0)"
blocks="$(cat "$blocks_file" 2>/dev/null || echo 0)"
[ "$blocks" -ge 0 ] 2>/dev/null || blocks=0
[ "$round" -ge 0 ] 2>/dev/null || round=0

# Hard safety: never trap Claude past a few rounds.
if [ "$blocks" -ge 6 ]; then clear_state; exit 0; fi

# A clean Codex review of the current changes → let Claude finish.
if [ "$reviewed_hash" = "$current_hash" ] && [ "$findings" = "0" ]; then
  clear_state
  exit 0
fi

# Otherwise block, and tell Claude exactly what to do. If the block counter
# cannot be persisted, allow the stop rather than block forever below the cap.
blocks=$((blocks + 1))
echo "$blocks" > "$blocks_file" 2>/dev/null || exit 0

cmd="bash ~/.web-xp/tools/code-loop.sh"
how="Options for a finding you do not simply fix: to dispute it or ask how it is triggered, write your reasoning to ${resp_file} and re-run the loop (Codex reconsiders). For a finding whose answer depends on the use-case or product intent, do not fix or dismiss it yourself — describe how it could happen by accident, then create ${ask_marker} and stop to ask the user, and record their decision in prd/review-exclusions.md."

if [ "$reviewed_hash" != "$current_hash" ]; then
  reason="Your code has uncommitted changes Codex has not reviewed in their current form. Hand them to Codex now: run ${cmd}. State the round number and Codex's findings. ${how}"
elif [ "$round" -ge 3 ]; then
  reason="Codex has reviewed these exact changes ${round} times and still reports ${findings} finding(s). Do not present this as done. Summarize the unresolved findings and ask the user how to proceed."
else
  reason="Codex round ${round} reported ${findings} finding(s) on these changes that are not yet resolved. Fix the ones you agree with and run ${cmd} again. ${how}"
fi

jq -n --arg r "$reason" '{decision:"block", reason:$r}'
exit 0
