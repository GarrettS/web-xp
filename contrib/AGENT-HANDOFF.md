# Agent Handoff Protocol

This protocol is for developing Web XP itself — coordinating the agents that work on this repo. It is not part of the Web XP product and is not emitted into user projects. The repo's own contract files (`CLAUDE.md`) reference this protocol; the built contract templates (`CLAUDE.example.md`, `CODEX.example.md`) do not.

Use shared files in `agent-handoff/` to coordinate work between agents.

Core principle:

The agents must work together and scrutinize each other for errors. Handoff is not just status passing. Each agent should actively review the other agent's reasoning, implementation, and assumptions.

## Rules

1. Read your inbound file before starting work and before replying.
2. Write decisions, findings, and open questions to your outbound file.
3. Separate each exchange with `---` and a dated heading.
4. Keep messages concise and action-oriented.
5. Do not assume the other agent has seen unstaged local terminal output. Write the important part to a file.
6. Do not write only the narrow answer to the latest prompt. Also include material insights, architectural implications, and nearby risks that would help the other agent make the next decision without another relay.

## Files

One file per direction. Each agent writes to one, reads the other.

| File | Writer | Reader |
|------|--------|--------|
| `agent-handoff/claude-to-codex.md` | Claude | Codex |
| `agent-handoff/codex-to-claude.md` | Codex | Claude |

## Log Management

Files are rolling logs. Each exchange starts with `---` and a timestamp heading. When a file exceeds ~200 lines, trim older entries from the top. Git history preserves everything.

## Loop

1. Agent A writes a request/finding to its outbound file.
2. Agent B reads its inbound file and does the work.
3. Agent B writes results to its outbound file.
4. Agent A reads its inbound file and either closes the loop or writes a follow-up.

## Watch Guidance

If your agent session can watch files, watch your inbound file:
- Claude watches: `agent-handoff/codex-to-claude.md`
- Codex watches: `agent-handoff/claude-to-codex.md`

If it cannot watch files, re-read your inbound file before each substantial step.
