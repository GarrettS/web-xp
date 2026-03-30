# Claude: smux Dev Workflow Spike

## Context

You are continuing work on the Web XP project (`~/.web-xp/` or this repo). Read `CLAUDE.md` first, then `contrib/AGENT-HANDOFF.md` for the handoff protocol.

The previous session (see git history) accomplished:
- Renamed doctrine → web-xp
- Agent-agnostic architecture (DESIGN.md)
- Claude and Codex adapters built and tested
- External install model (`~/.web-xp/`)
- Shared `AGENT.md` build source for both contracts
- Comment-aware pre-commit override system with regression tests
- `contrib/` directory for contributor tooling
- ORCHESTRATION.md design notes

## This session's task

Build a small smux/tmux-bridge spike in `contrib/smux/` to reduce manual agent relay during Web XP development.

### The problem

Currently Claude and Codex coordinate via file-based handoff (`agent-handoff/claude-to-codex.md`, `agent-handoff/codex-to-claude.md`). The human has to:
- Tell Codex "check your inbox"
- Poll or manually check for Codex's response
- Relay status between agents

This is tedious and error-prone.

### The goal

Replace manual relay with tmux-bridge messaging. Agents in separate panes notify each other directly. The human stays in control of approvals but doesn't have to be the router.

### Constraints

- This is contributor tooling, not user-facing
- Web XP core stays unchanged
- smux spike lives in `contrib/smux/`
- Codex cannot self-invoke between turns — the human still triggers Codex, but the notification/relay overhead should drop
- Start small: prove the workflow, iterate

### Collaboration

You are working with Codex. Use the handoff protocol:
- Read `agent-handoff/codex-to-claude.md` before substantial work
- Write to `agent-handoff/claude-to-codex.md` when you need Codex's input
- Be eager: propose, act, tell Codex what you did, ask for review. Don't wait to be told.
- When the poll triggers or you're asked to check, read the file immediately and act on it.
- Always restart the poll after acting.

### Moving forward

Be proactive. When you finish a piece of work:
1. Tell Codex what you did
2. Ask for review or next input
3. Poll for response
4. Act on it

Don't idle. Don't wait for the user to relay. Drive the loop.
