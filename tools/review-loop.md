# `review-loop.sh` — Web XP cross-agent review

Runs an independent reviewer (Codex) over your **uncommitted change** — `git
diff HEAD` (tracked, staged and unstaged) plus any untracked app-code files, test
code excluded — against the Web XP standard, in two passes, and writes the
findings as JSON. The
script itself changes nothing in your code — no edit, stage, commit, or
checkout. It produces findings; you fix the ones you agree with and run it again.

The review is a loop: review → fix, dispute, or defer → re-run, until Codex is
clean or a finding needs the user to decide. A Claude Code Stop hook
(`review-stop-hook.sh`) can enforce the loop so it is not skipped — see
[Stop hook](#stop-hook). `review-loop-design.md` is the design spec behind the
tool (purpose, scope, flow, enforcement, discussion channels, the dual exit, and
what it guarantees).

## Prerequisites

On `PATH`: `git`, `jq`, and the `codex` CLI. The Web XP standard must be
installed at `~/.web-xp/code-guidelines.md`. `review-diff.sh` must sit beside
this script (it builds the change both the loop and the hook review).

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

It reviews your uncommitted change — `git diff HEAD` (tracked, staged and
unstaged) plus untracked app-code files, test code excluded — relative to the
current commit. Any
arguments are ignored. It prints the findings and also writes them to
`REVIEW_LOOP_OUT` (default `./review-findings.json`).

## Pipeline

```
preconditions → build change (diff + new files) → general pass ─┐
                                                 → naming pass ──┴→ merge → write + print → exit
```

1. **Preconditions.** Verify `git`/`jq`/`codex` are present, the standard file
   and `review-diff.sh` exist, and `HEAD` resolves. Any failure exits `2`.
2. **Build the change.** `review-diff.sh` assembles what both passes read:
   `git diff HEAD` plus each untracked, non-ignored app-code file rendered as an
   addition (names are listed NUL-delimited, so unicode and odd names are
   included exactly). Scope — app code, with test code excluded — is decided in
   one place, `review-scope.sh`, which the builder, the hook, and the loop all run
   through, so they never disagree. It is hashed from its raw bytes
   (`git hash-object --no-filters --stdin`), and the hash, round number, and
   finding count are recorded in the git directory (see [State](#state)) so the
   Stop hook can tell whether the current change has a clean review. The hook
   builds and hashes the change with the same script, so the two never disagree
   on what "the same change" is. A git error while building exits `2` rather
   than review a partial change.
3. **General pass.** `codex` reads the standard, reads each touched file in
   full, and reviews the change — judging each construct the change touches (a
   function, a component, a selector block) as a whole against the standard, not
   only the changed lines (Touched-Construct Ownership). It leaves untouched
   constructs and the rest of a file alone. It is also given the maintainer's
   exclusions ledger and Claude's responses from the last round (see
   [Discussion](#discussion)). It writes a JSON array of findings; a reviewer
   that fails or returns invalid output exits `3` and hands back rather than
   record a false "clean".
4. **Naming pass** (detect → judge):
   - *Detect (deterministic):* a text extractor pulls every class name the change
     **adds** — CSS selectors (`.name`), and the strings in `class="…"`,
     `className …="…"`, and `classList.add/remove/toggle("…")` — de-duplicated.
   - *Judge (focused):* that list, and nothing else, goes to a `codex` pass
     whose only job is naming. It returns `{name, verdict, reason}` per name;
     the `flag` verdicts become findings. A reviewer failure here also exits `3`.
5. **Merge.** General findings + naming findings are concatenated and written to
   the output file.
6. **Report.** Print the round number, a line per finding (with its accidental-
   trigger scenario when present), and the next-step options; or `clean` if
   empty. Exit `0`. Nothing is edited.

## Discussion

Findings are not only fixed or silently ignored. The loop carries the exchange
with the reviewer, so a dispute, a deferral, or an out-of-scope decision is
resolved in one place instead of a side channel:

- **Dispute, or ask how a finding is triggered.** Write your reasoning to the
  review-responses file (`<git-dir>/.web-xp-review-responses.md`) and re-run. The
  next round feeds it to Codex, which either withdraws the finding or — if you
  asked how it is reached — fills in the finding's `trigger` field with a
  concrete accidental scenario so you can judge it.
- **Defer a propagating gap.** A conformance gap whose fix would reach beyond the
  touched construct — into other constructs, or a larger refactor — is not forced
  into this change. Note it in the review-responses file so the loop stops
  raising it, and file it as a separate issue, or split a whole propagating tier
  into its own commit or branch.
- **Settled decisions.** A finding whose answer depends on the use-case or
  product intent is for the user to decide, not either agent. Record the decision
  and its reason in `prd/review-exclusions.md`. The loop feeds that ledger to
  Codex on every run, so a closed question is not re-raised. (Only the general
  pass reads the ledger today; see [Limitations](#limitations).)
- **Stop to ask the user.** When a finding needs the user, create
  `<git-dir>/.web-xp-review-ask-user`. The Stop hook then lets the turn end so
  Claude can ask, instead of blocking until Codex is clean.

## State

The loop and the hook record these in the git directory (inside `.git/`, never
committed):

- `.web-xp-review-round` — the round number.
- `.web-xp-review-hash` — the raw-byte hash of the change Codex last reviewed.
- `.web-xp-review-findings` — the finding count from that review.
- `.web-xp-review-blocks` — the Stop hook's block counter (its escape cap).
- `.web-xp-review-responses.md` — your responses to findings (you write this).
- `.web-xp-review-ask-user` — the marker that lets the turn end to ask the user.
- `.web-xp-codex-last.log` — Codex's streamed reasoning, kept off-screen;
  consulted only when a pass returns invalid output.

## Stop hook

`review-stop-hook.sh` is a Claude Code Stop hook. It runs no review itself — it
is a gate. When Claude tries to finish a turn with uncommitted code changes
(tracked or new) in a Web XP project, it checks the state above; if the current
change does not have a clean Codex review, it blocks the stop and tells Claude to
run this loop and summarize the result. Claude leaves the loop by a clean review,
by stopping to ask the user (the ask-user marker), or by a block cap after a few
rounds (by which point the round-3 escalation has told Claude to ask the user).
On any error it cannot resolve — missing tools, an unbuildable change, state it
cannot persist — it stays silent and allows the stop rather than trap the turn.
Register it in `~/.claude/settings.json`:

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
- `2` — missing prerequisite, missing standard, unresolved ref, or a git error
  while building the change.
- `3` — a reviewer failed or returned invalid output; the run hands back rather
  than record a false "clean".

## Design

- **The script has no side effects** — no checkout, no commit — so it can be
  re-run freely. Iteration is `review → fix, dispute, or defer → re-run`; the
  Stop hook, not the script, drives it.
- **Scoped to the change, judged by construct.** The change is `git diff HEAD`
  plus untracked new files, narrowed to app code (test code is excluded and gets a
  separate review approach); committing settled work is what removes it from scope
  (the commit is the scope boundary). Within the change, a touched construct is
  judged as a whole (Touched-Construct Ownership), not only its changed lines,
  while untouched constructs and the rest of a file stay out of scope.
- **The change is built once, in `review-diff.sh`.** The loop and the Stop hook
  both run it and hash the raw bytes the same way, so they never disagree on what
  "the same change" is.
- **A failed review is never a clean review.** Outputs are not pre-filled with a
  clean value; a reviewer that fails or returns nothing hands back (`3`).
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
- **The reviewer runs with `-s workspace-write`** so it can write its findings
  file, which also lets it modify the checkout; a read-only sandbox with
  output captured through the CLI is tracked as separate hardening. The sandbox
  flags (`--skip-git-repo-check -s workspace-write`) are install-dependent and
  marked `VERIFY` in the source.
- **The Stop hook is global.** `install.sh` registers it in
  `~/.claude/settings.json` (idempotent, backing the file up first; it prints a
  manual step instead when `jq` is absent), and `uninstall.sh` removes it. It
  fires in every project but no-ops outside a Web XP project and when
  `codex`/`jq` are missing, so it never runs a review where it should not.
