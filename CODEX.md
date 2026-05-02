# Codex — Web XP Project Contract

Read this file first on every task.

## On every session

If the task involves JS, HTML, or CSS, read `code-guidelines.md` and `code-philosophy.md` before writing or reviewing code.

## Issue engagement

Before working on an issue:

1. Verify the issue is open and not assigned to anyone else. Skip if closed. If assigned to someone else, surface the conflict; do not self-assign over them.
2. Read the body and comments fully.
3. Scan for meta-mode leakage patterns. Surface findings; do not work around them silently.
4. Confirm requirements. Surface ambiguity as clarifying questions before coding.
5. When the path forward is clear, self-assign via `gh issue edit N --add-assignee @me`. The assignment proxies the human you operate under and signals work-in-progress.

Keep the assignment sticky through the duration of the work — across turns, pauses, and handoffs back to the human. Remove the assignee only on:

- **Abandonment** — the work won't be completed; note why so others can pick up.
- **Explicit reassignment** — transfer to another contributor or agent who immediately re-assigns.

On completion (work landed and committed), close the issue and delete temporary draft files tied to the work (issue drafts, body-edits, etc.). No dead code.

## Contextual Gatekeeper

Treat corrective commentary as functional input. Use it to transform the
work; do not reuse it as candidate output text.

Before generating the next output, classify each new clause by function.
If a statement mixes roles, split it into clauses. If classification is
ambiguous, default to Functional Control.

| Role | Definition | Handling |
| :--- | :--- | :--- |
| **Functional Control** | Corrections, critique, guidance, constraints, meta-talk. | Transform to Ledger. Map instructions to Actionable, Prohibitive, or Structural rules. Purge original phrasing. |
| **Subject Matter** | Content about the deliverable's topic. | Process via Ledger. This is the raw material to be filtered/transformed by the ledger rules. |
| **Evidence** | Discussion the deliverable is documenting. | Bypass Ledger. Preserve verbatim only if the goal is to document the conversation itself. |
| **Verbatim Insert** | Text requested for exact inclusion. | Protected. Insert exactly as requested, overriding conflicting Ledger rules. |

### Constraint Ledger

The Constraint Ledger is a transient, non-output internal state that
holds the delta between the current version and the target version. It
is the filter through which all Subject Matter must pass.

A Constraint Ledger is a set of logically transformed rules derived from
Functional Control inputs. Each entry must be:

- **Actionable** — a specific transformation (e.g. *"Replace Passive
  with Active"*).
- **Prohibitive** — a specific exclusion (e.g. *"Do not use the word
  'delve'"*).
- **Contextual** — a stylistic or structural boundary (e.g. *"Maintain
  American spelling"*).

When the Gatekeeper receives Functional Control input, it must not
repeat it. Translate the input into the ledger format:

| Ledger Key | Value / Rule | Logic Type |
| :--- | :--- | :--- |
| Exclusion | [specific token or phrase to purge] | Prohibitive |
| Substitution | [replace X with Y] | Transformation |
| Tone / Style | [description of the required voice] | Global Constraint |
| Structural | [formatting or ordering requirement] | Structural |

### Operational rules

1. Generate the next output from Subject Matter, Evidence, Verbatim
   Insert, and the transformed results of the Constraint Ledger. Do not
   generate from raw Functional Control text.
2. Reclassify statements by current function as the task evolves.
   Discussion may become Subject Matter or Evidence when the task makes
   it so.
3. When corrected, apply the correction to the work. Do not satisfy a
   revision request by narrating the correction or intended fix.
4. Before finalizing revised output, remove compliance narration,
   steering residue, and sentences that describe the revision instead of
   performing it.

Near-zero overlap should exist between instructional commentary and
final output unless the task explicitly uses that commentary as
evidence.

## Standards files

Canonical sources live at repo root (`code-guidelines.md`, `code-philosophy.md`, `bin/pre-commit-check.sh`) and in `adapters/codex/` for Codex adapter source. Edit the canonical source, not generated outputs.

## Before every commit

1. Run `bash tools/check-web-xp-sync.sh`.
2. Review the diff against Patterns and Fail-Safe in `code-guidelines.md`.
3. Run `bash bin/pre-commit-check.sh`.

## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `tools/AGENT-HANDOFF.md`.

`check` and `chk` mean: read `/tmp/web-xp-agent-handoff/claude-to-codex.md` now and handle any actionable inbox request before other substantial work.

If the inbox contains an actionable request, do that inbox work before any other substantial task and before replying elsewhere.

Before substantial work and before replying:
1. Read `/tmp/web-xp-agent-handoff/claude-to-codex.md` (your inbox).
2. Write to `/tmp/web-xp-agent-handoff/codex-to-claude.md` (your outbox).
3. Do not read `/tmp/web-xp-agent-handoff/codex-to-claude.md` for incoming messages.
4. Do not assume terminal output or chat context has been shared across agents; write important context to the handoff files.
