# Review Workflow Loop — Design

This is the design the code conforms to. It states what the loop is for, what
it reviews, the flow, where it is enforced, how disputes are settled, when the
work may be presented, and the failure modes the design exists to prevent.
`review-loop.md` is the usage and reference doc; this is the model behind it.

## Purpose

Code the user's agent (Claude) writes gets an independent review from a second
agent (Codex) before Claude presents the result. Claude authors; Codex reviews
against the Web XP standard; the two iterate; the user decides the questions
that depend on the product, not the standard.

Two things the loop is for:

- Catch Web XP standard violations in the new code before the user sees it as
  done.
- Settle a disputed or use-case-dependent finding with the user, rather than
  letting either agent decide it alone.

## What it reviews

`git diff HEAD` — the uncommitted change in the working tree, staged and
unstaged, relative to the current commit. This is the change the agent is
working on.

It is not a diff against `main` and not a diff against a merge-base. For a
branch, the change is the diff on that branch's worktree HEAD. Reviewing against
`main` pulls in work already handled earlier on the branch and makes the
reviewer re-flag it, which drives re-edits of settled code. Scoping to
`git diff HEAD` keeps the review on the current change only.

## Flow

1. Claude writes the code for the user's task.
2. Before presenting, Claude runs `bash ~/.web-xp/tools/review-loop.sh`. Codex
   reviews `git diff HEAD` and returns findings as JSON.
3. For each finding, Claude does one of:
   - fixes it — the user approves the change through their normal approval flow;
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
with the result, including whether to commit it.

The review happens before presenting. So the handoff to Codex always comes
before the result is presented. Presenting a proposed change without first
handing it to Codex is the error the loop exists to stop — including when the
change is correct.

## Enforcement

A Claude Code Stop hook (`review-stop-hook.sh`) enforces the loop at turn-end.
It runs no review itself; it is a gate. When Claude tries to end a turn with
uncommitted code changes in a Web XP project, the hook checks whether Codex has
given those exact changes a clean review (recorded by `review-loop.sh` in the
git directory). If not, it blocks the stop and tells Claude to run the loop and
report the result in the conversation.

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
- **Exclusions ledger** (`prd/review-exclusions.md`): the maintainer's settled
  out-of-scope decisions, with reasons. Fed to Codex every run, so a question
  the user has already closed is not re-raised.
- **Trigger field** (per finding): when Claude asks how a finding is reached,
  Codex fills in a concrete accidental-trigger scenario so the user can judge
  the risk.
- **Ask-user marker** (in the git directory): lets the turn end so Claude can
  ask the user, without the hook re-blocking.

## Dual exit

The loop ends one of two ways:

- Codex is clean **and** Claude is confident the work meets the requirement →
  present it.
- Codex is not clean, or Claude's confidence is not high enough (ambiguous
  requirement, contested finding, or a fix that may miss the intent) → stop and
  ask the user.

## Failure modes this design prevents

- **Presenting un-reviewed work.** The handoff to Codex must precede the
  presentation. The Stop hook blocks a turn that ends with unreviewed changes.
- **Re-flagging already-handled work.** Reviewing against `main` or a merge-base
  re-surfaces work already done on the branch. The loop reviews `git diff HEAD`,
  so only the current change is judged.
- **Oscillating on a reverted decision.** A decision the user has settled is
  recorded in the exclusions ledger and fed to Codex, so it is not re-raised and
  re-reverted on a later round.
- **An agent deciding a use-case question alone.** A finding whose answer depends
  on product intent goes to the user, with the accidental-trigger scenario
  described, and the decision is recorded — not fixed or dismissed by either
  agent.
