# `review-loop.sh` — Web XP cross-agent review

Runs an independent reviewer (Codex) over your **uncommitted working changes**
against the Web XP standard, in two passes, and writes the findings as JSON. The
script itself changes nothing in your code — no edit, stage, commit, or
checkout. It produces findings; you fix the ones you agree with and run it again.

The review is a loop: review → fix or dispute → re-run, until Codex is clean or
a finding needs the user to decide. A Claude Code Stop hook
(`review-stop-hook.sh`) can enforce the loop so it is not skipped — see
[Stop hook](#stop-hook).

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
tools/review-loop.sh
```

```bash
cd <your-repo>
bash ~/.web-xp/tools/review-loop.sh
```

It reviews `git diff HEAD` — your uncommitted changes (staged and unstaged)
relative to the current commit. Any arguments are ignored. It prints the
findings and also writes them to `REVIEW_LOOP_OUT` (default
`./review-findings.json`).

## Pipeline

```
preconditions → diff working tree → general pass ─┐
                                   → naming pass ──┴→ merge → write + print → exit
```

1. **Preconditions.** Verify `git`/`jq`/`codex` are present, the standard file
   exists, and `HEAD` resolves. Any failure exits `2`.
2. **Diff.** `git diff HEAD` — your uncommitted changes relative to the current
   commit — into a temp file both passes read. The diff is hashed and the hash,
   round number, and finding count are recorded in the git directory (see
   [State](#state)) so the Stop hook can tell whether the current changes have a
   clean review.
3. **General pass.** `codex` reads the standard and reviews the whole diff,
   flagging only added/changed lines. It is also given the maintainer's
   exclusions ledger and Claude's responses from the last round (see
   [Discussion](#discussion)). It writes a JSON array of findings; the result is
   schema-validated and invalid JSON exits `3`.
4. **Naming pass** (detect → judge):
   - *Detect (deterministic):* a text extractor pulls every class name the diff
     **adds** — CSS selectors (`.name`), and the strings in `class="…"`,
     `className …="…"`, and `classList.add/remove/toggle("…")` — de-duplicated.
   - *Judge (focused):* that list, and nothing else, goes to a `codex` pass
     whose only job is naming. It returns `{name, verdict, reason}` per name;
     the `flag` verdicts become findings.
5. **Merge.** General findings + naming findings are concatenated and written to
   the output file.
6. **Report.** Print the round number, a line per finding (with its accidental-
   trigger scenario when present), and the next-step options; or `clean` if
   empty. Exit `0`. Nothing is edited.

## Discussion

Findings are not only fixed or silently ignored. The loop carries the exchange
with the reviewer, so a dispute or an out-of-scope decision is resolved in one
place instead of a side channel:

- **Dispute, or ask how a finding is triggered.** Write your reasoning to the
  review-responses file (`<git-dir>/.web-xp-review-responses.md`) and re-run. The
  next round feeds it to Codex, which either withdraws the finding or — if you
  asked how it is reached — fills in the finding's `trigger` field with a
  concrete accidental scenario so you can judge it.
- **Settled decisions.** A finding whose answer depends on the use-case or
  product intent is for the user to decide, not either agent. Record the decision
  and its reason in `prd/review-exclusions.md`. The loop feeds that ledger to
  Codex on every run, so a closed question is not re-raised. (Only the general
  pass reads the ledger today; see [Limitations](#limitations).)
- **Stop to ask the user.** When a finding needs the user, create
  `<git-dir>/.web-xp-review-ask-user`. The Stop hook then lets the turn end so
  Claude can ask, instead of blocking until Codex is clean.

## State

The loop records these in the git directory (inside `.git/`, never committed):

- `.web-xp-review-round` — the round number.
- `.web-xp-review-hash` — the hash of the diff Codex last reviewed.
- `.web-xp-review-findings` — the finding count from that review.
- `.web-xp-review-responses.md` — your responses to findings (you write this).
- `.web-xp-review-ask-user` — the marker that lets the turn end to ask the user.
- `.web-xp-codex-last.log` — Codex's streamed reasoning, kept off-screen;
  consulted only when a pass returns invalid JSON.

## Stop hook

`review-stop-hook.sh` is a Claude Code Stop hook. It runs no review itself — it
is a gate. When Claude tries to finish a turn with uncommitted code changes in a
Web XP project, it checks the state above; if the current changes do not have a
clean Codex review, it blocks the stop and tells Claude to run this loop and
summarize the result. Claude leaves the loop by a clean review, by stopping to
ask the user (the ask-user marker), or by a block cap after a few rounds (which
tells Claude to ask the user rather than loop forever). Register it in
`~/.claude/settings.json`:

```json
"hooks": { "Stop": [ { "hooks": [ { "type": "command", "command": "bash ~/.web-xp/tools/review-stop-hook.sh" } ] } ] }
```

It stays silent (allows the stop) outside a Web XP project, when `codex`/`jq`
are missing, or when `review-loop: off` is set in the project overlay.

## Output

A JSON array of findings. Each:

```json
{ "file": "string", "line": 0, "rule": "string", "problem": "string", "fix": "string", "trigger": "string" }
```

`trigger` describes how the problem is reached, especially by accident, when the
finding's seriousness depends on that; it is `""` for a clear-cut rule violation.
Naming findings carry `file: ""`, `line: 0` — the class name is in `problem`; the
fixer locates references by name.

## Exit codes

- `0` — completed (clean, or findings written).
- `2` — missing prerequisite, missing standard, or unresolved ref.
- `3` — the general reviewer returned invalid JSON; the run hands back rather
  than guess.

## Design

- **The script has no side effects** — no checkout, no commit — so it can be
  re-run freely. Iteration is `review → fix or dispute → re-run`; the Stop hook,
  not the script, drives it.
- **Diff-scoped.** Only added/changed lines are judged. Pre-existing violations
  below the diff waterline are out of scope by design.
- **Two passes, because naming is a *systematic* blind spot.** The free-form
  general pass reliably drops class-name violations when heavier findings compete
  for attention (observed on a real diff: `.inp`, `.muted`, `.inline-value` sat
  in the added lines and went unflagged). The dedicated enumerate-then-judge
  naming pass guarantees the sweep.

## Limitations

- **Not a completion gate on its own.** A clean result is not proof of
  conformance.
- **The general pass is stochastic** — different runs surface different findings.
  For higher recall, run it several times and union; the naming pass is
  near-deterministic and needs no resampling.
- **The naming extractor is text, not a parser** — it over-extracts at the
  margins (harmless; the judge filters) and does not see class names built by
  string concatenation.
- **Only the general pass reads the exclusions ledger.** A class-name decision
  cannot yet be excluded; the naming pass still flags it.
- **codex sandbox flags** (`--skip-git-repo-check -s workspace-write`) are
  install-dependent and marked `VERIFY` in the source.
- **The Stop hook is global.** `install.sh` registers it in
  `~/.claude/settings.json` (idempotent, backing the file up first; it prints a
  manual step instead when `jq` is absent), and `uninstall.sh` removes it. It
  fires in every project but no-ops outside a Web XP project and when
  `codex`/`jq` are missing, so it never runs a review where it should not.
