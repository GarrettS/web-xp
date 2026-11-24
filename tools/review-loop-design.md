# Review Workflow Loop — Design

This states the design of the Review Workflow Loop: what it is for, what it
reviews, the flow, where it is enforced, how disputes are settled, and when the
work may be presented. `review-loop.md` is the usage and reference doc.

## Purpose

Code the user's agent (Claude) writes gets an independent review from a second
agent (Codex) before Claude presents the result. Claude authors; Codex reviews
against the Web XP standard; the two iterate; the user decides the questions
that depend on the product, not the standard.

What the loop is for:

- Catch Web XP standard violations in the change before the user sees it as
  done.
- Hold the change to Touched-Construct Ownership. When the change edits a
  construct — a function, a component, a selector block — that whole construct
  must conform to the standard, not only the lines that changed. The loop judges
  the touched construct, kept proportionate: the construct the change touched,
  not the untouched rest of the file.
- Settle a disputed or use-case-dependent finding with the user, rather than
  letting either agent decide it alone.

## What it reviews

The change is `git diff HEAD` — the working tree compared to the current commit,
staged and unstaged, plus untracked files that are not ignored, narrowed to app
code. For a branch, that is the diff on the branch's worktree HEAD. It is not a
diff against `main` or a merge-base.

App code is the files the standard governs: `.js`, `.mjs`, `.ts`, `.html`,
`.css`. Test code is out of scope — it gets a separate review approach, so the
loop does not judge it, and a turn that touches only test code does not trigger
it. A path is test code when it has a test directory anywhere in it (`test*/`,
`__tests__/`, `spec/`, `e2e/`) or its file name is `*.test.*` or `*.spec.*`. One
place — `review-scope.sh`, which `review-diff.sh`, the hook, and the loop all run
through — decides this, so they never disagree about what is in scope.

### The commit is the scope boundary

`git diff HEAD` is "what changed since the last commit." So committing is how
work leaves the review surface: once a task is finished, reviewed, and
presented, committing it advances `HEAD`, and the next task's review —
`git diff HEAD` again — sees only the next task's edits, measured against the
committed work as a fixed baseline.

This is the control for scope. The commit granularity is the review granularity.
Commit at task boundaries and each review is one task against a stable baseline.
Leave several tasks uncommitted in one tree and they are reviewed together.

It is also what keeps the loop from thrashing. A finished, committed task is not
in `git diff HEAD` anymore, so the reviewer cannot re-flag settled choices and
send the agent back to undo them. If a later task changes an earlier task's
committed code, that edit is reviewed as the later task's own change against the
committed baseline — the one line it changed, not the whole earlier task.

### Scope of judgment

A construct the change touches is judged as a whole against the standard —
Touched-Construct Ownership — not only on the lines that changed. The reviewer
is given the whole touched construct, not just the changed lines and a few lines
of context, so it can see where the function or selector block begins and ends
and judge it entire. Constructs the change did not touch, and the rest of the
file, stay out of scope.

Two bounds keep this from running away:

- **Ownership attaches to what the change reworks, not to a construct it only
  touches to update a reference.** A
  construct touched only by a mechanical reference update — a rename's call
  sites, an import path — is not audited as a whole; only the reference edit
  must be correct. This stops a fix from pulling new constructs into scope round
  after round.
- **Judge the whole construct, but fix only what is proportionate and local.** A
  gap a safe, local change closes — a rename, an extraction, a dead branch — is
  a blocking finding: fix it. A gap whose fix would propagate into other
  constructs, or needs a real refactor, is not fixed here: the agent reports it,
  writes it to the review-responses file so the loop stops raising it for the
  rest of this change, and — with the user — files it as a separate issue, or
  splits a whole propagating tier (an app-wide rename, a builder refactor) into
  its own commit or branch, so the current change stays focused and the work is
  not lost.

The reviewer's authority is conformance to the standard, not the choice of
approach. The loop does not revert the task's own change on the reviewer's
say-so. A clear standard violation is fixed to conform — the goal stays, the
method is brought into line. A finding that would undo or redesign the intended
change, and is a judgment call rather than a clear violation, is a use-case
decision: it goes to the user, is recorded once settled, and is not raised
again. Committing the settled change takes it out of scope for good.

### Untracked and scratch files

New app-code files the change adds are in scope: the review renders each
untracked, non-ignored app-code file as an addition, and the hook's gate and its
"same changes" check count them too. This is done without staging — the review
does not mutate the user's index. A scratch or ad hoc app-code file left in the
tree is therefore reviewed like anything else, which forces the choice the
standard already requires: make it a real test — which moves it into a test
directory and out of this loop's scope — or delete it. No dead code. Non-code
files and test code are not rendered, so they neither get judged nor change the
hash.

## Flow

1. Claude writes the code for the user's task.
2. Before presenting, Claude runs `bash ~/.web-xp/tools/review-loop.sh`. Codex
   reviews the change and returns findings as JSON.
3. For each finding, Claude does one of:
   - fixes it — the user approves the change through their normal approval flow;
   - defers it, when fixing it properly would change more than the touched
     construct — propagate into other constructs, or need a larger refactor:
     does not force it into this change, records it in the review-responses file
     so the loop stops raising it, and files it as a separate issue, or splits a
     whole propagating tier into its own commit or branch;
   - disputes it, or asks how it is triggered — writes the reasoning to the
     review-responses file; Codex reconsiders next round;
   - if the answer depends on the use-case or product intent — describes how the
     problem could happen by accident, stops, and asks the user; the decision is
     recorded in `prd/review-exclusions.md`.
4. Re-runs the loop and repeats the handling until Codex returns no findings.
5. Presents only when Codex is clean and Claude is confident the work meets the
   requirement. Otherwise stops and asks the user.

### What "present" means

Present is Claude handing the finished, reviewed result back to the user at the
end of the turn. It is not commit and not deploy. The user decides what to do
with the result, including whether to commit it. Committing a presented task is
what settles it and sets the baseline for the next task's review.

The review happens before presenting: the handoff to Codex comes before the
result is presented.

## Enforcement

A Claude Code Stop hook (`review-stop-hook.sh`) enforces the loop at turn-end.
It runs no review itself; it is a gate. When Claude tries to end a turn with
uncommitted code changes — tracked or new — in a Web XP project, the hook checks
whether Codex has given those exact changes a clean review (recorded by
`review-loop.sh` in the git directory). If not, it blocks the stop and tells
Claude to run the loop and report the result in the conversation.

Claude leaves the loop three ways:

- a clean Codex review of the current changes (the hook allows the stop);
- the ask-user marker — Claude is deferring a use-case decision to the user, so
  the hook lets the turn end;
- a block cap after a few rounds — an unfixable or contested finding cannot trap
  the turn; the hook tells Claude to ask the user and allows the stop.

The hook stays silent (allows the stop) outside a Web XP project, when
`codex`/`jq` are missing, or when `review-loop: off` is set in the project
overlay.

## Discussion channels

Findings are not only fixed or silently dropped. The exchange with the reviewer,
and with the user, runs inside the loop:

- **Review-responses file** (in the git directory): Claude's disputes and
  requests to explain a trigger. Fed to Codex the next round, so a dispute is
  answered in the loop, not through a side channel.
- **Exclusions ledger** (`prd/review-exclusions.md`): the user's settled
  out-of-scope decisions, with reasons. Fed to Codex every run, so a question
  the user has already closed is not re-raised.
- **Trigger field** (per finding): Codex fills in a concrete accidental-trigger
  scenario so the user can judge the risk.
- **Ask-user marker** (in the git directory): lets the turn end so Claude can
  ask the user, without the hook re-blocking.
- **The user's question to the agent**: on any finding, the user can ask the
  agent to explain it — how it is reached, why it matters here — and the agent
  answers from the code and the task before the user decides, not only when it
  defers.

## Dual exit

The loop ends one of two ways:

- Codex is clean **and** Claude is confident the work meets the requirement →
  present it.
- Codex is not clean, or Claude's confidence is not high enough (ambiguous
  requirement, contested finding, or a fix that may miss the intent) → stop and
  ask the user.

## What the design guarantees

- Nothing is presented without a clean Codex review of it. The Stop hook gates
  the turn on the review, not on Claude's own judgment that the code is fine.
- No use-case question is settled by an agent alone. A finding whose answer
  depends on product intent goes to the user, with the accidental-trigger
  scenario described, and the decision is recorded.
