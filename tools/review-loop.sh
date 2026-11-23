#!/usr/bin/env bash
#
# review-loop.sh — the cross-agent review, run without a human relay.
#
# Codex reviews a branch's diff against the Web XP standard and returns findings
# as JSON. Two passes run each time:
#   - a GENERAL pass over the whole diff against the whole standard;
#   - a NAMING pass that pulls every class name the diff adds out of the text,
#     then judges only those names, so a class-name sweep happens even when
#     heavier architectural findings would otherwise crowd it out.
# The two results are merged, printed, and written to a file.
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
#   tools/review-loop.sh <branch> [base-branch]
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

branch="${1:?usage: review-loop.sh <branch> [base-branch]}"
base="${2:-main}"

standard="${WEB_XP_CG:-$HOME/.web-xp/code-guidelines.md}"
out="${REVIEW_LOOP_OUT:-review-findings.json}"

# Temp files: the general pass output, the raw naming verdicts, the naming
# findings derived from them, and the diff both passes read. The merged result
# is written to $out and kept.
general="$(mktemp)"
naming_raw="$(mktemp)"
naming_findings="$(mktemp)"
diff_file="$(mktemp)"
trap 'rm -f "$general" "$naming_raw" "$naming_findings" "$diff_file"' EXIT

# Fail early and plainly if a prerequisite is missing. No `claude` — this script
# does not fix anything.
for tool in git jq codex; do
  command -v "$tool" >/dev/null || { echo "missing required tool: $tool"; exit 2; }
done
[ -f "$standard" ] || { echo "standard not found: $standard (run install.sh)"; exit 2; }
git rev-parse --verify "$branch" >/dev/null 2>&1 || { echo "no such branch: $branch"; exit 2; }
git rev-parse --verify "$base" >/dev/null 2>&1 || { echo "no such base: $base"; exit 2; }

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

# --- review ---
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

# Naming pass, then merge both into the findings file.
run_naming_pass
jq -s '.[0] + .[1]' "$general" "$naming_findings" > "$out"

count="$(jq 'length' "$out")"
if [ "$count" -eq 0 ]; then
  echo "✓ clean — no findings"
  exit 0
fi

echo
echo "${count} finding(s) — written to ${out}:"
jq -r '.[] | "  \(.file):\(.line) [\(.rule)] \(.problem)"' "$out"
echo
echo "Review only — nothing was edited or committed. Hand ${out} to Claude to fix interactively."
exit 0
