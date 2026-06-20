# Web XP — Project Contract

Read this file first on every task.

## On every session

If the task involves JS, HTML, or CSS, read `code-guidelines.md` and `code-philosophy.md` before writing or reviewing code. The `web-xp` skill performs these reads.

## Issue engagement

When asked about an issue, first determine what's being asked: explanation of the issue text, planning advice (triage, scoping, sequencing), or implementation. Ask if unclear. The protocol below applies to implementation requests; explanation and planning requests stop at the answer.

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

**Duplicate avoidance.** Before filing an issue or posting a comment, search the tracker for existing duplicates. Issues, comments, files — same rule: search before adding. If a duplicate is found, reference the existing artifact rather than creating another.

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

Canonical doctrine sources at repo root: `code-guidelines.md`, `code-philosophy.md`, `editorial-rules.md`, `bin/pre-commit-check.sh`.

Adapter sources: `adapters/shared-base/skills/` (shared skill sources), `adapters/claude/` (Claude adapter packaging), `adapters/codex/` (Codex adapter packaging). Always edit the shared/canonical source, never generated adapter output.

`.claude/skills/` is gitignored — populated by `bin/install.sh` at install time, not tracked.

## Before every commit

Most commits (markdown, docs, contracts, MAINTAINERS.md): review the diff against Patterns and Fail-Safe in `code-guidelines.md`. No automated check applies.

Conditional checks:

- When changing `adapters/shared-base/`: run `bash tools/check-web-xp-sync.sh` to rebuild generated adapter outputs.
- When changing doctrine (`code-guidelines.md`, `code-philosophy.md`): run the `web-xp-check` skill for a doctrine audit.
- When changing scripts in `bin/` or `tools/`: run `bash test/run-unit.sh`.

Note: `bin/pre-commit-check.sh` is the user-facing script distributed to user projects via `bin/web-xp-on`. Do not run it on this repo.

## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `tools/AGENT-HANDOFF.md`.

Each agent reads its own inbox and writes its own outbox:

- **Claude:** reads `/tmp/web-xp-agent-handoff/codex-to-claude.md`, writes `/tmp/web-xp-agent-handoff/claude-to-codex.md`.
- **Codex:** reads `/tmp/web-xp-agent-handoff/claude-to-codex.md`, writes `/tmp/web-xp-agent-handoff/codex-to-claude.md`.

Before substantial work and before replying: read the inbox; write to the outbox; don't assume terminal output or chat context has been shared.

When the human says **check** or **chk**: read the inbox immediately and handle actionable inbox work before other substantial work.

## Edit tool

When changing multiple locations in the same file, use one edit call with an `old_string` span that covers all change sites. Never send parallel edit calls to the same file.
