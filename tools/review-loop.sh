#!/usr/bin/env bash
#
# review-loop.sh — the cross-agent review, run without a human relay.
#
# Codex reviews your uncommitted change — `git diff HEAD` (tracked, staged and
# unstaged) plus any untracked new code files — against the Web XP standard and
# returns findings as JSON. Two passes run each time:
#   - a GENERAL pass over the whole change against the whole standard, judging
#     each touched construct as a whole (Touched-Construct Ownership);
#   - a NAMING pass that pulls every class name the change adds out of the text,
#     then judges only those names, so a class-name sweep happens even when
#     heavier architectural findings would otherwise crowd it out.
# The two results are merged, printed, and written to a file.
#
# A reviewer that fails or returns nothing hands the review back (exit 3); it is
# never recorded as a clean result.
#
# It is REVIEW ONLY. It does not edit, stage, commit, or check out anything. It
# produces the findings and hands them back — fixing is done interactively, with
# Claude reading the code and the person in the loop, because naming the right
# domain concept takes judgment the review cannot make for you.
#
# (The name is historical: the "loop" was the manual relay between the two
#  agents. This script removes that relay; it no longer iterates.)
#
# Usage:
#   tools/review-loop.sh
#
# Reviews your uncommitted change — `git diff HEAD` plus untracked new code
# files — relative to the current commit. Any arguments are ignored.
#
# Output: prints the findings, and writes them as a JSON array to
# $REVIEW_LOOP_OUT (default ./review-findings.json) for Claude to read.
#
# Needs on PATH: git, jq, the `codex` CLI.
# Needs the standard installed at ~/.web-xp/code-guidelines.md (run install.sh).
#
# The codex invocation depends on how codex behaves in your install; it is
# marked VERIFY below.
#
set -euo pipefail
shopt -s nocasematch

# Sibling scripts: the shared change-set builder (review-diff.sh), located by
# this script's own directory so it works however the script is invoked. The
# Stop hook builds the change the same way, so the two agree on the hash.
script_dir="$(cd "${0%/*}" 2>/dev/null && pwd)"
diff_builder="${script_dir}/review-diff.sh"

standard="${WEB_XP_CG:-$HOME/.web-xp/code-guidelines.md}"
out="${REVIEW_LOOP_OUT:-review-findings.json}"

# Temp files: the general pass output, the raw naming verdicts, the naming
# findings derived from them, the change both passes read, and the touched-file
# list. The merged result is written to $out and kept.
general="$(mktemp)"
naming_raw="$(mktemp)"
naming_findings="$(mktemp)"
diff_file="$(mktemp)"
touched_tmp="$(mktemp)"
trap 'rm -f "$general" "$naming_raw" "$naming_findings" "$diff_file" "$touched_tmp"' EXIT

# Fail early and plainly if a prerequisite is missing. No `claude` — this script
# does not fix anything.
for tool in git jq codex; do
  command -v "$tool" >/dev/null || { echo "missing required tool: $tool"; exit 2; }
done
[ -f "$standard" ] || { echo "standard not found: $standard (run install.sh)"; exit 2; }
[ -f "$diff_builder" ] || { echo "missing change-set builder: $diff_builder (reinstall)"; exit 2; }
git rev-parse --verify HEAD >/dev/null 2>&1 || { echo "no commit to diff against (HEAD is unborn)"; exit 2; }

# A usable result is a JSON array whose every element carries the five fields
# with the right types. Length alone does not prove that, and an empty or
# truncated file must not pass as "clean".
valid_findings() {
  jq -e 'type == "array" and all(.[];
    (.file | type == "string") and (.line | type == "number") and
    (.rule | type == "string") and (.problem | type == "string") and
    (.fix | type == "string"))' "$1" >/dev/null 2>&1
}

# Detect step of the naming pass: pull candidate class names out of the ADDED
# lines of the change. Two sources: CSS selector lines that begin with a class
# (".name"), and the class strings in class="...", className ...="...", and
# classList.add/remove/toggle("..."). Multi-class strings are split into words,
# results are filtered to valid class tokens and de-duplicated. It is text, not
# a parser, so it over-extracts at the margins — harmless, since the judge keeps
# non-issues. It does not see class names built by string concatenation.
extract_class_names() {
  {
    # CSS selectors: added lines whose first non-space character is a class dot.
    grep -E '^\+[[:space:]]*\.' "$1" | grep -oE '\.[A-Za-z][-_A-Za-z0-9]*' | tr -d '.'
    # Class strings in HTML/JS, anchored on the keyword so other quoted text on
    # the line (textContent, placeholders) is not captured. Handles both quote
    # styles.
    grep '^+' "$1" \
      | grep -oE "class=[\"'][^\"']*[\"']|className[[:space:]:=]+[\"'][^\"']*[\"']|classList\.[a-z]+\([^)]*\)" \
      | grep -oE "[\"'][^\"']*[\"']" | tr -d "\"'" | tr ' ' '\n'
  } | grep -E '^[A-Za-z][-_A-Za-z0-9]*$' | sort -u
}

# Judge step: hand the enumerated names to a reviewer whose only job is naming,
# then turn each flagged name into a review finding. A reviewer failure or
# invalid output hands the whole review back rather than quietly dropping the
# naming sweep.
run_naming_pass() {
  echo "[]" > "$naming_findings"
  local names
  names="$(extract_class_names "$diff_file")" || true
  [ -n "$names" ] || { echo "  naming pass: no class names added"; return 0; }
  echo "  naming pass: judging $(printf '%s\n' "$names" | grep -c .) class name(s)"
  : > "$naming_raw"
  local naming_rc=0
  # VERIFY: --skip-git-repo-check -s workspace-write let codex write the file in
  # testing; confirm on your install that it emits only JSON into that file.
  # Codex streams its whole reasoning to stdout; this script never reads that —
  # it reads only the JSON file Codex writes — so send the stream to the hidden
  # log instead of the user's screen.
  codex exec --skip-git-repo-check -s workspace-write "Read ${standard}. Below are class names added in one diff, one per \
line. Judge EACH name on its own against that standard's rule on semantic class \
and id selectors: flag names that describe appearance, a layout box, a visual \
rank, the widget the element already is, or that abbreviate the element type; a \
name must carry the domain concept; state and modifier names such as editing, \
invalid, or busy are acceptable. Write ONLY a JSON array to ${naming_raw}; each \
element {\"name\":\"\",\"verdict\":\"flag\" or \"keep\",\"reason\":\"\"}. Put \
nothing else in that file. Names:
${names}" < /dev/null >> "$codex_log" 2>&1 || naming_rc=$?
  if [ "$naming_rc" -ne 0 ]; then
    echo "  naming pass: reviewer did not complete (exit ${naming_rc}) — handing back to you (see ${codex_log})"
    exit 3
  fi
  jq '[.[] | select(.verdict == "flag") | {
        file: "", line: 0,
        rule: "CSS — Semantic class and id selectors",
        problem: ("class `" + .name + "` is generic, presentational, or restates the element type: " + .reason),
        fix: ("Name the domain concept that `" + .name + "` represents and update every reference, or drop the class and style the element or attribute.")
      }]' "$naming_raw" > "$naming_findings" 2>/dev/null \
    || { echo "  naming pass: judge did not return valid JSON — handing back to you (see ${codex_log})"; exit 3; }
  echo "  naming pass: $(jq 'length' "$naming_findings" 2>/dev/null || echo 0) name(s) flagged"
}

# --- review ---

# Round tracking + state, shared with the Stop hook (review-stop-hook.sh). These
# files in the git dir record which change Codex last reviewed, how many findings
# it had, and the round number. The hook reads them to decide whether Claude may
# finish its turn. The change is built the same way in both places
# (review-diff.sh) and hashed the same way (raw bytes), so they agree on what
# "the same change" means.
gitdir="$(git rev-parse --git-dir 2>/dev/null || echo .git)"
round_file="${gitdir}/.web-xp-review-round"
hash_file="${gitdir}/.web-xp-review-hash"
findings_file="${gitdir}/.web-xp-review-findings"
resp_file="${gitdir}/.web-xp-review-responses.md"
ask_marker="${gitdir}/.web-xp-review-ask-user"

# Codex's streamed reasoning goes here, not to the user's screen. Overwritten
# each run; only consulted when a pass returns invalid JSON.
codex_log="${gitdir}/.web-xp-codex-last.log"
: > "$codex_log" 2>/dev/null || codex_log=/dev/null

prev_round="$(cat "$round_file" 2>/dev/null || echo 0)"
[ "$prev_round" -ge 0 ] 2>/dev/null || prev_round=0
round=$((prev_round + 1))

echo "── Handoff to Codex · round ${round} — reviewing your uncommitted change (git diff HEAD plus any new files) ──"
bash "$diff_builder" > "$diff_file" || { echo "could not build the change set (git error) — handing back to you"; exit 2; }
# Hash the raw bytes, the same command the Stop hook uses, so the two never
# disagree because of input filters (e.g. core.autocrlf).
diff_hash="$(git hash-object --no-filters --stdin < "$diff_file")" || { echo "could not hash the change — handing back to you"; exit 2; }

# The code files the change touches — tracked changes plus untracked new files,
# listed NUL-delimited so odd names stay exact. Codex reads each in full to judge
# a touched construct as a whole.
{ git diff --name-only -z HEAD 2>/dev/null; git ls-files --others --exclude-standard -z 2>/dev/null; } > "$touched_tmp"
touched_files=""
while IFS= read -r -d '' f; do
  case "$f" in
    *.js|*.mjs|*.ts|*.html|*.css) touched_files="${touched_files}${f}"$'\n' ;;
  esac
done < "$touched_tmp"
touched_files="$(printf '%s' "$touched_files" | sort -u)"

# Discussion context fed to Codex alongside the change:
#   - the maintainer's settled decisions (prd/review-exclusions.md), so Codex
#     stops re-raising questions the user has already closed;
#   - Claude's responses to the last round's findings (resp_file), so a dispute
#     or a request to explain a trigger is answered inside the loop, not through
#     a side channel.
context=""
if [ -f prd/review-exclusions.md ]; then
  echo "  feeding Codex the maintainer's review-exclusions ledger"
  context="${context}
The maintainer has decided the following are out of scope and must NOT be flagged (each with its reason). Do not raise these again:
$(cat prd/review-exclusions.md)
"
fi
if [ -f "$resp_file" ]; then
  echo "  feeding Codex Claude's responses from the last round"
  context="${context}
In a prior round you raised findings. Claude has responded below. Re-review the current change accordingly: if you accept a response, do not re-raise that finding; if you still disagree, raise it again and address Claude's point; if Claude asks how a problem is reached, put a concrete accidental-trigger scenario in that finding's \"trigger\" field.
$(cat "$resp_file")
"
fi

# General pass: the whole standard, over the whole change, judging each touched
# construct as a whole. Do NOT pre-fill a clean value — if Codex fails or writes
# nothing, the empty file fails validation and we hand back rather than certify
# a false "clean".
: > "$general"
general_rc=0
codex exec --skip-git-repo-check -s workspace-write "Read ${standard}. The change under review is the unified diff in ${diff_file}. It touches these code files:
${touched_files}
Read each of those files in full from the working tree, then review the change against that standard. Apply Touched-Construct Ownership: for every construct the diff touches — a function, a component, a selector block — judge the WHOLE construct against the standard, not only the lines that changed, so a changed line left inside a nonconforming construct is caught. Do NOT flag constructs the diff does not touch, or the rest of a file; a construct touched only to update a reference (a renamed symbol's call sites, an import path) needs only that reference correct, not a whole-construct audit. Keep each fix proportionate and local — a rename, an extraction, a dead branch; if bringing a touched construct into conformance would require changing other constructs or a larger refactor, say so in the finding's \"fix\" so it can be deferred to a separate issue rather than forced now.
${context}
Write ONLY a JSON array to ${general}. Each element: {\"file\":\"\",\"line\":0,\"rule\":\"\",\"problem\":\"\",\"fix\":\"\",\"trigger\":\"\"}. In \"trigger\", when a finding's seriousness depends on how it is reached, describe how it could happen in normal use, especially by accident; use \"\" for a clear-cut rule violation. Use [] when there are no violations. Put nothing else in that file." < /dev/null >> "$codex_log" 2>&1 || general_rc=$?
if [ "$general_rc" -ne 0 ]; then
  echo "general reviewer did not complete (exit ${general_rc}) — handing back to you (see ${codex_log})"
  exit 3
fi
valid_findings "$general" \
  || { echo "general reviewer did not return valid findings JSON — handing back to you (see ${codex_log})"; exit 3; }

# Naming pass, then merge both into the findings file.
run_naming_pass
jq -s '.[0] + .[1]' "$general" "$naming_findings" > "$out"

count="$(jq 'length' "$out")"

# Record what Codex reviewed so the hook can gate Claude's finish on it.
echo "$round"     > "$round_file"     2>/dev/null || true
echo "$diff_hash" > "$hash_file"      2>/dev/null || true
echo "$count"     > "$findings_file"  2>/dev/null || true

if [ "$count" -eq 0 ]; then
  echo "── Codex round ${round} response: clean — no findings ──"
  echo "Codex is satisfied. If you are confident the work meets the requirement, present it to the user."
  exit 0
fi

echo
echo "── Codex round ${round} response: ${count} finding(s) ──"
jq -r '.[] | "  \(.file):\(.line) [\(.rule)] \(.problem)" + (if (.trigger // "") != "" then "\n      how it happens: " + .trigger else "" end)' "$out"
echo
echo "Next steps:"
echo "  - Fix each finding you agree with, then run this script again (round $((round + 1)))."
echo "  - To dispute a finding, or to ask how it is triggered, write your reasoning to ${resp_file} and re-run; Codex will reconsider and, if asked, describe the accidental-trigger scenario."
echo "  - For a finding whose answer depends on the use-case or product intent, do not fix or dismiss it yourself: describe how it could happen by accident, then create ${ask_marker} and stop to ask the user. Record their decision and the reason in prd/review-exclusions.md."
exit 0
