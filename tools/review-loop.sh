#!/usr/bin/env bash
#
# review-loop.sh — the cross-agent review loop, run without a human relay.
#
# One agent (Codex) reviews a branch's diff against the Web XP standard and
# returns findings as JSON. The other agent (Claude) reads the code around each
# finding, applies the fix, and commits. The loop repeats until the reviewer
# returns no findings and a mechanical check passes, or a round cap is reached,
# then it hands back to you. You run it once instead of relaying messages
# between the two agents by hand.
#
# Each round runs two reviewers. A GENERAL pass reviews the whole diff against
# the whole standard. A NAMING pass pulls every class name the diff adds out of
# the text, then judges only those names — so the class-name sweep happens every
# round even when heavier architectural findings would otherwise crowd it out.
# A real dogfood run showed the general pass alone silently skipped generic
# names (.inp, .muted, .inline-value) that were sitting in the added lines; the
# naming pass exists to close that hole.
#
# What it is and is not. It contains violations after they are generated. It
# does NOT make the author write conforming code in the first place, and a clean
# review is not by itself proof of conformance. Use it as an extra check, not as
# the completion gate.
#
# Usage:
#   tools/review-loop.sh <branch> [base-branch] [max-rounds]
#
# Needs on PATH: git, jq, the `codex` CLI, the `claude` CLI.
# Needs the standard installed at ~/.web-xp/code-guidelines.md (run install.sh).
#
# Spots that depend on how each CLI behaves in your install are marked VERIFY.
# Test on a throwaway branch before trusting it unattended.
#
set -euo pipefail

branch="${1:?usage: review-loop.sh <branch> [base-branch] [max-rounds]}"
base="${2:-main}"
max_rounds="${3:-3}"

standard="${WEB_XP_CG:-$HOME/.web-xp/code-guidelines.md}"

# Optional mechanical gate, run before the loop reports "clean" — the project's
# own tests or Web XP pre-commit check. Empty skips it (with a printed note).
check_cmd="${REVIEW_LOOP_CHECK:-}"

# VERIFY: acceptEdits auto-applies file edits but may still stop on the git
# commit. For a fully unattended run, set CLAUDE_FLAGS=--dangerously-skip-permissions
# — only on a branch you are willing to let it change without asking.
claude_flags="${CLAUDE_FLAGS:---permission-mode acceptEdits}"

# Temp files: the merged findings the fixer sees, the general pass output, the
# raw naming verdicts, the naming findings derived from them, and the diff both
# passes read.
findings="$(mktemp)"
general="$(mktemp)"
naming_raw="$(mktemp)"
naming_findings="$(mktemp)"
diff_file="$(mktemp)"
trap 'rm -f "$findings" "$general" "$naming_raw" "$naming_findings" "$diff_file"' EXIT

# Fail early and plainly if a prerequisite is missing.
for tool in git jq codex claude; do
  command -v "$tool" >/dev/null || { echo "missing required tool: $tool"; exit 2; }
done
[ -f "$standard" ] || { echo "standard not found: $standard (run install.sh)"; exit 2; }
git rev-parse --verify "$branch" >/dev/null 2>&1 || { echo "no such branch: $branch"; exit 2; }

# The loop commits on the branch, so the working tree must start and stay empty
# — no unstaged, staged, or untracked changes. Otherwise they ride into the
# fixer's commits or get diffed as the branch's own work.
require_clean_tree() {
  [ -z "$(git status --porcelain)" ] \
    || { echo "working tree not clean (unstaged, staged, or untracked changes) — commit, stash, or remove them first"; exit 2; }
}
require_clean_tree

git checkout "$branch" >/dev/null 2>&1

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
# lines of the diff. Two sources: CSS selector lines that begin with a class
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
# then turn each flagged name into a review finding.
run_naming_pass() {
  echo "[]" > "$naming_findings"
  local names
  names="$(extract_class_names "$diff_file")"
  [ -n "$names" ] || { echo "  naming pass: no class names added"; return 0; }
  echo "  naming pass: judging $(printf '%s\n' "$names" | grep -c .) class name(s)"
  : > "$naming_raw"
  # VERIFY: --skip-git-repo-check -s workspace-write let codex write the file in
  # testing; confirm on your install that it emits only JSON into that file.
  codex exec --skip-git-repo-check -s workspace-write "Read ${standard}. Below are class names added in one diff, one per \
line. Judge EACH name on its own against that standard's rule on semantic class \
and id selectors: flag names that describe appearance, a layout box, a visual \
rank, the widget the element already is, or that abbreviate the element type; a \
name must carry the domain concept; state and modifier names such as editing, \
invalid, or busy are acceptable. Write ONLY a JSON array to ${naming_raw}; each \
element {\"name\":\"\",\"verdict\":\"flag\" or \"keep\",\"reason\":\"\"}. Put \
nothing else in that file. Names:
${names}" < /dev/null
  jq '[.[] | select(.verdict == "flag") | {
        file: "", line: 0,
        rule: "CSS — Semantic class and id selectors",
        problem: ("class `" + .name + "` is generic, presentational, or restates the element type: " + .reason),
        fix: ("Name the domain concept that `" + .name + "` represents and update every reference, or drop the class and style the element or attribute.")
      }]' "$naming_raw" > "$naming_findings" 2>/dev/null \
    || { echo "  naming pass: judge did not return valid JSON — skipping naming findings"; echo "[]" > "$naming_findings"; }
  echo "  naming pass: $(jq 'length' "$naming_findings" 2>/dev/null || echo 0) name(s) flagged"
}

run_review() {
  echo "── codex reviewing ${base}...${branch} ──"
  git diff "${base}...${branch}" > "$diff_file"

  # General pass: the whole standard, over the whole diff.
  echo "[]" > "$general"
  # VERIFY: --skip-git-repo-check -s workspace-write let codex write the file in
  # testing; confirm on your install that it emits only JSON into that file.
  codex exec --skip-git-repo-check -s workspace-write "Read ${standard}. Review the unified diff in ${diff_file} against \
that standard. Flag only added or changed lines, but read the full diff for \
context. Write ONLY a JSON array to ${general}. Each element: \
{\"file\":\"\",\"line\":0,\"rule\":\"\",\"problem\":\"\",\"fix\":\"\"}. Use [] \
when there are no violations. Put nothing else in that file." < /dev/null
  valid_findings "$general" \
    || { echo "general reviewer did not return valid findings JSON — handing back to you"; exit 3; }

  # Naming pass, then merge both into the findings the fixer sees.
  run_naming_pass
  jq -s '.[0] + .[1]' "$general" "$naming_findings" > "$findings"
}

run_fix() {
  echo "${1} finding(s):"
  jq -r '.[] | "  \(.file):\(.line) [\(.rule)] \(.problem)"' "$findings"
  # Fixer. Claude reads the code around each finding, applies the fix, and
  # commits. For a naming finding it reads the component — the markup and the
  # JS/CSS that reference the name — so it names the domain concept the element
  # represents and updates every reference, rather than swapping one generic
  # name for another or renaming a selector while leaving its callers behind.
  claude -p "On git branch ${branch} in this repo, apply these Web XP review \
findings, then commit. Findings: $(cat "$findings"). For each finding, read the \
markup and code around it before editing. For a naming finding, name the domain \
concept the element represents — read the component's HTML and the JS and CSS \
that reference the name to choose it — and update every reference to the old \
name; do not replace one generic, widget, or layout name with another, and drop \
the class if no domain concept fits. A fix may require editing dependent markup, \
CSS, or JS beyond the line named. Commit with a message listing the rules \
fixed." ${claude_flags} < /dev/null
  git checkout "$branch" >/dev/null 2>&1
  require_clean_tree   # the fixer's own commit must leave the tree clean
}

# Run the project's mechanical gate if one is set. A clean review is not proof
# of conformance on its own; this is the second half of "ready".
run_check() {
  [ -n "$check_cmd" ] \
    || { echo "no mechanical check set (REVIEW_LOOP_CHECK) — skipping; a clean review alone is not proof of conformance"; return 0; }
  echo "── running mechanical check: ${check_cmd} ──"
  bash -c "$check_cmd" || { echo "mechanical check failed — handing back to you"; exit 4; }
}

# Review; if clean, confirm with the mechanical check and finish; else fix.
for (( round = 1; round <= max_rounds; round++ )); do
  echo "── round $round ──"
  run_review
  count="$(jq 'length' "$findings")"

  if [ "$count" -eq 0 ]; then
    run_check
    echo "✓ clean review and check passed after ${round} round(s) — ready for your review"
    exit 0
  fi

  run_fix "$count"
done

# Cap reached. The last thing that ran was a fixer round, so review once more:
# the final state, not the pre-fix findings, is what we report.
echo "── final review after ${max_rounds} rounds ──"
run_review
count="$(jq 'length' "$findings")"
if [ "$count" -eq 0 ]; then
  run_check
  echo "✓ clean on the final review after ${max_rounds} rounds — ready for your review"
  exit 0
fi
echo "✗ still ${count} finding(s) after ${max_rounds} rounds — handing back to you"
jq -r '.[] | "  \(.file):\(.line) [\(.rule)] \(.problem)"' "$findings"
exit 1
