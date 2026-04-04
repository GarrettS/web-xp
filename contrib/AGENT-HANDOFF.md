# Agent Handoff Protocol

This protocol is for developing Web XP itself — coordinating the agents that work on this repo. It is not part of the Web XP product and is not emitted into user projects. The repo's own contract files (`CLAUDE.md`) reference this protocol; the built contract templates (`CLAUDE.example.md`, `CODEX.example.md`) do not.

Use shared files in `agent-handoff/` to coordinate work between agents.

Core principle:

The agents must work together and scrutinize each other for errors. Handoff is not just status passing. Each agent should actively review the other agent's reasoning, implementation, and assumptions. When reading and replying, keep this core principle in mind.

## Rules

0. Keep the core principle in mind.
1. Read your inbox before starting work and before replying. Think. Be insightful.
2. If the inbox contains an actionable request, do that inbox work before any other substantial task and before replying elsewhere.
3. If the actionable request requires a reply when done, write that reply to your outbox.
4. Write decisions, findings, and open questions to your outbox.
5. Every message starts with `---` and an ISO 8601 extended format timestamp heading to the second (e.g. `## 2026-04-02T20:30:45-07:00`). Read the message with the latest timestamp — that is the current message.
6. Keep messages concise and action-oriented.
7. Do not assume the other agent has seen terminal output. Write the important part to the file.
8. Include material insights, architectural implications, and nearby risks — not just the narrow answer. 
9. When replying with pushback, give reasons. Explain why.
10. For multi-step tasks, complete each step, notify the other agent(s) and the human, then proceed to the next. Short; a few lines at most per step — include reasons and relevant details, but don't narrate every file edit. When all steps are done, notify again.
11. Any questions, concerns, or problems: ask.

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

## Message Order

<!-- Newest-first order follows email conventions and addresses a
     recurring problem: Codex repeatedly reads from the top of the
     file regardless of instructions. Rather than fight that tendency,
     the protocol now matches it — the newest message is always at
     the top, so reading from the top means reading the current message. -->

New messages go at the **top** of the file, below the `# heading` line. The newest message is always first. Read from the top — the first timestamped message is the current one.

## Message Retention

Each file keeps only the **four most recent timestamped messages**. When writing a new message:

1. Prepend your new message below the `# heading` line.
2. Count the total timestamped messages (lines starting with `## 20`).
3. If there are more than four, delete the oldest messages from the bottom until only four remain.

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
