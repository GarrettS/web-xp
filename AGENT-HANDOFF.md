# Agent Handoff Protocol

Use shared files in `agent-handoff/` to coordinate work between agents.

## Rules

1. Read your inbox before starting work and before replying.
2. Write decisions, findings, and open questions to your outbox.
3. Keep entries append-only. Add a dated heading for each new entry.
4. Keep messages concise and action-oriented.
5. Do not assume the other agent has seen unstaged local terminal output. Write the important part to a file.

## Files

- `agent-handoff/inbox-claude.md` — messages intended for Claude
- `agent-handoff/outbox-claude.md` — Claude's responses and status
- `agent-handoff/inbox-codex.md` — messages intended for Codex
- `agent-handoff/outbox-codex.md` — Codex's responses and status

## Suggested Loop

1. User or another agent writes a request to an inbox file.
2. The target agent reads its inbox and does the work.
3. The target agent writes results to its outbox.
4. The requesting side reads the outbox and either closes the loop or writes a follow-up.

## Watch Guidance

If your agent session can watch files, watch:

- `AGENT-HANDOFF.md`
- `agent-handoff/inbox-claude.md`
- `agent-handoff/outbox-claude.md`
- `agent-handoff/inbox-codex.md`
- `agent-handoff/outbox-codex.md`

If it cannot watch files, re-read your inbox before each substantial step.
