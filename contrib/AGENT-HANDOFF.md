# Agent Handoff Protocol

This protocol is for developing Web XP itself — coordinating the agents that work on this repo. It is not part of the Web XP product and is not emitted into user projects. The repo's own contract files (`CLAUDE.md`) reference this protocol; the built contract templates (`CLAUDE.example.md`, `CODEX.example.md`) do not.

Use shared files in `agent-handoff/` to coordinate work between agents.

Core principle:

The agents must work together and scrutinize each other for errors. Handoff is not just status passing. Each agent should actively review the other agent's reasoning, implementation, and assumptions.

## Rules

1. Read your inbox before starting work and before replying.
2. Write decisions, findings, and open questions to your outbox.
3. Every message starts with `---` and a timestamp heading (e.g. `## 2026-04-02 20:30 PDT`).
4. Keep messages concise and action-oriented.
5. Do not assume the other agent has seen terminal output. Write the important part to the file.
6. Include material insights, architectural implications, and nearby risks — not just the narrow answer.

## Files

One file per direction. Each agent writes to one, reads the other.

**Do not read your own outbox for incoming messages.**

Handoff files are gitignored. Do not commit them. They are ephemeral working state, not repo content.

### Claude

- **Read** (your inbox): `agent-handoff/codex-to-claude.md`
- **Write** (your outbox): `agent-handoff/claude-to-codex.md`

### Codex

- **Read** (your inbox): `agent-handoff/claude-to-codex.md`
- **Write** (your outbox): `agent-handoff/codex-to-claude.md`

## Message Retention

Each file keeps only the **four most recent timestamped messages**. When writing a new message:

1. Append your new message to the end of the file.
2. Count the total timestamped messages (lines starting with `## 20`).
3. If there are more than four, delete the oldest messages from the top until only four remain.

Git history preserves everything. The file should stay short and current. Long files cause agents to lose context and read the wrong content.

## Human Shorthand

The human may use shorthand to direct handoff actions:

- **check**, **chk** — read your inbox now
- **tell**, **ask** — write a message to the other agent's inbox now

## Loop

1. Agent A writes a request/finding to its outbox.
2. Agent B reads its inbox and does the work.
3. Agent B writes results to its outbox.
4. Agent A reads its inbox and either closes the loop or writes a follow-up.

## Watch Guidance

If your agent session can watch files, watch your inbox:
- Claude watches: `agent-handoff/codex-to-claude.md`
- Codex watches: `agent-handoff/claude-to-codex.md`

If it cannot watch files, re-read your inbox before each substantial step.
