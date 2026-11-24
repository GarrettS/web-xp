#!/usr/bin/env bash
#
# review-stop-hook.sh — Claude Code Stop hook for the Web XP Review Workflow Loop.
#
# This hook does NOT run Codex. It is a gate. When Claude tries to finish a turn
# with uncommitted code changes, it checks whether Codex has given those exact
# changes a clean review (recorded by review-loop.sh in the git dir). If not, it
# blocks the stop and tells Claude to run the review loop itself and summarize
# the result — so the handoff, Codex's response, and Claude's fixes all happen
# visibly in the conversation instead of silently inside this hook.
#
# Claude can leave the loop three ways:
#   - a clean Codex review of the current changes (the hook allows the stop);
#   - stopping to ask the user about a finding whose answer depends on the
#     use-case (Claude creates the ask-user marker and the hook lets it pause);
#   - a block cap, so an unfixable or contested finding cannot trap it.
#
set -uo pipefail

# Stop-hook input arrives as JSON on stdin; we need the project cwd.
input="$(cat 2>/dev/null || true)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -n "$cwd" ] || cwd="$PWD"
cd "$cwd" 2>/dev/null || exit 0

# Branch Claude merges into. MUST match the base Claude passes to review-loop.sh,
# or the two will hash different diffs and never agree the review is current.
base="main"

# --- gates: stay silent (allow the stop) unless everything lines up ---
[ -f AGENTS.md ] || [ -f CLAUDE.md ] || [ -f CODEX.md ] || exit 0
command -v codex >/dev/null 2>&1 && command -v jq >/dev/null 2>&1 || exit 0
[ -f "$HOME/.web-xp/code-guidelines.md" ] || exit 0
if [ -f prd/project.md ] && grep -iqE 'review-loop:[[:space:]]*off' prd/project.md; then exit 0; fi
# Any uncommitted tracked code changes (staged or unstaged) to review?
git diff --name-only HEAD 2>/dev/null | grep -qiE '\.(js|mjs|ts|html|css)$' || exit 0

gitdir="$(git rev-parse --git-dir 2>/dev/null || echo .git)"
round_file="${gitdir}/.web-xp-review-round"
hash_file="${gitdir}/.web-xp-review-hash"
findings_file="${gitdir}/.web-xp-review-findings"
blocks_file="${gitdir}/.web-xp-review-blocks"
resp_file="${gitdir}/.web-xp-review-responses.md"
ask_marker="${gitdir}/.web-xp-review-ask-user"

clear_state() { rm -f "$round_file" "$hash_file" "$findings_file" "$blocks_file" "$resp_file"; }

# Claude is deferring a finding to the user. Let it pause, once per marker.
if [ -f "$ask_marker" ]; then rm -f "$ask_marker"; exit 0; fi

# The diff Codex would review right now — computed exactly as review-loop.sh does.
current_hash="$(git diff "$(git merge-base "${base}" HEAD 2>/dev/null)" 2>/dev/null | git hash-object --stdin 2>/dev/null || echo none)"

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

# Otherwise block, and tell Claude exactly what to do.
blocks=$((blocks + 1))
echo "$blocks" > "$blocks_file"

cmd="bash ~/.web-xp/tools/review-loop.sh HEAD ${base}"
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
