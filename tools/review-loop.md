# `review-loop.sh` — Web XP cross-agent review

A review-only tool. It runs an independent reviewer (Codex) over a branch's diff
against the Web XP standard, in two passes, and writes the findings as JSON. It
does **not** edit, stage, commit, or iterate — it produces findings and hands
them back. Fixing is done interactively, where naming the right domain concept
takes judgment the review cannot make.

(The name is historical: the "loop" was the manual relay between the two agents.
This script removes that relay; it no longer iterates.)

## Prerequisites

On `PATH`: `git`, `jq`, and the `codex` CLI. The Web XP standard must be
installed at `~/.web-xp/code-guidelines.md`.

### jq

The findings are JSON; the script uses `jq` to validate, filter, and merge them.
`jq` is a small single binary — install is seconds, not minutes.

```bash
# Homebrew, skipping the slow auto-update step:
HOMEBREW_NO_AUTO_UPDATE=1 brew install jq

# Or the standalone binary — no Homebrew, instant. Check your chip first with
# `uname -m`: arm64 = Apple Silicon, x86_64 = Intel (use amd64).
curl -L -o /usr/local/bin/jq \
  https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-arm64 \
  && chmod +x /usr/local/bin/jq

jq --version   # confirm
```

### Codex CLI

Install and authenticate the `codex` CLI and confirm it is on `PATH`
(`command -v codex`). The script invokes it headless with
`--skip-git-repo-check -s workspace-write` so it can run outside a trusted
directory and write its findings file.

### Web XP standard

```bash
git clone https://github.com/GarrettS/web-xp.git ~/.web-xp && ~/.web-xp/bin/install.sh
# update later:
git -C ~/.web-xp pull && ~/.web-xp/bin/install.sh
```

Override the standard's path with the `WEB_XP_CG` environment variable if it
lives elsewhere.

## Usage

```bash
tools/review-loop.sh <branch> [base-branch]
```

- `<branch>` — the ref to review (`HEAD` for the current branch).
- `[base-branch]` — what to diff against; defaults to `main`.

```bash
# review the current branch against main, findings to ~/review-findings.json
cd <your-repo>
REVIEW_LOOP_OUT=~/review-findings.json bash review-loop.sh HEAD main
```

It prints the findings and writes them to `REVIEW_LOOP_OUT` (default
`./review-findings.json`). It computes the diff from refs and makes no change to
the working tree — so it tolerates a dirty tree and does not care which branch
is checked out. No worktree or clean tree is required.

## Pipeline

```
preconditions → diff → general pass ─┐
                     → naming pass ──┴→ merge → write + print → exit
```

1. **Preconditions.** Verify `git`/`jq`/`codex` are present, the standard file
   exists, and both `<branch>` and `<base>` resolve. Any failure exits `2`.
2. **Diff.** Compute `git diff <base>...<branch>` (three-dot: changes on the
   branch since it diverged from base) into a temp file both passes read.
3. **General pass.** `codex` reads the standard and reviews the whole diff,
   flagging only added/changed lines, and writes a JSON array of findings. The
   result is schema-validated; invalid JSON exits `3`.
4. **Naming pass** (detect → judge):
   - *Detect (deterministic):* a text extractor pulls every class name the diff
     **adds** — CSS selectors (`.name`), and the strings in `class="…"`,
     `className …="…"`, and `classList.add/remove/toggle("…")` — de-duplicated.
   - *Judge (focused):* that list, and nothing else, goes to a `codex` pass
     whose only job is naming. It returns `{name, verdict, reason}` per name;
     the `flag` verdicts become findings.
5. **Merge.** General findings + naming findings are concatenated and written to
   the output file.
6. **Report.** Print a one-line summary per finding (or `clean` if empty), then
   exit `0`. Nothing is edited.

## Output

A JSON array of findings. Each:

```json
{ "file": "string", "line": 0, "rule": "string", "problem": "string", "fix": "string" }
```

Naming findings carry `file: ""`, `line: 0` — the class name is in `problem`;
the fixer locates references by name.

## Exit codes

- `0` — completed (clean, or findings written).
- `2` — missing prerequisite, missing standard, or unresolved ref.
- `3` — the general reviewer returned invalid JSON; the run hands back rather
  than guess.

## Design

- **Review-only / pure function.** No checkout, no commit, no side effects — so
  it can be re-run freely. Iteration lives *outside* the tool:
  `review → interactive fix → re-run`. Keeping fixing out avoids a headless
  process botching the naming call and committing blind, and sidesteps the
  permission wall a non-interactive fixer hits.
- **Diff-scoped.** Only added/changed lines are judged. Pre-existing violations
  below the diff waterline are out of scope by design.
- **Two passes, because naming is a *systematic* blind spot.** The free-form
  general pass reliably drops class-name violations when heavier findings
  compete for attention (observed on a real diff: `.inp`, `.muted`,
  `.inline-value` sat in the added lines and went unflagged). The dedicated
  enumerate-then-judge naming pass guarantees the sweep.

## Limitations

- **Not a completion gate.** A clean result is not proof of conformance.
- **The general pass is stochastic** — different runs surface different findings.
  For higher recall, run it several times and union; the naming pass is
  near-deterministic and needs no resampling.
- **The naming extractor is text, not a parser** — it over-extracts at the
  margins (harmless; the judge filters) and does not see class names built by
  string concatenation.
- **codex sandbox flags** (`--skip-git-repo-check -s workspace-write`) are
  install-dependent and marked `VERIFY` in the source.

## Where it fits

The tool is the automated half of the Codex↔Claude review: it replaces the
manual relay of running the reviewer and copying findings back. The interactive
Claude consumes `review-findings.json`, reports to the person, and fixes with
them in the loop. Contested findings — the reviewer flags something the author
judges correct — are negotiated through the Codex↔Claude handoff channel
(`/tmp/web-xp-agent-handoff/`), with the person arbitrating; once an accepted
finding is committed, diff-scoping drops it from later reviews.
