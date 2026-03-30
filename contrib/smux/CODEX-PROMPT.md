# Codex: smux Dev Workflow Spike

## Context

You are continuing work on the Web XP project. Read `AGENT.md` first, then any repo-specific Codex contract if present, then `contrib/AGENT-HANDOFF.md` for the handoff protocol.

The previous session (see git history) accomplished:
- Agent-agnostic architecture (DESIGN.md)
- Claude and Codex adapters built and tested against elitefuellabs.com
- External install model (`~/.web-xp/`)
- Shared `AGENT.md` build source for both contracts
- Comment-aware pre-commit override system with regression tests
- `contrib/` directory for contributor tooling
- ORCHESTRATION.md design notes capturing task composition patterns

## This session's task

Collaborate with Claude to build a small smux/tmux-bridge spike in `contrib/smux/` that reduces manual agent relay during Web XP development.

### The problem

Currently you and Claude coordinate via file-based handoff (`agent-handoff/claude-to-codex.md`, `agent-handoff/codex-to-claude.md`). The human has to:
- Tell you "check your inbox"
- Tell Claude to check for your response
- Relay status between you

This makes the human the router, which is the exact problem we want to solve.

### The goal

Replace manual relay with tmux-bridge messaging. Both agents in tmux panes, notifying each other directly. The human stays in control of approvals but doesn't route messages.

### Your role

You are the reviewer and design advisor. Claude will propose and implement. You:
- Review Claude's proposals and implementations
- Flag errors, inconsistencies, and overclaims
- Push back when something is wrong — don't rubber-stamp
- Propose alternatives when you see a better path
- Test in your environment where possible

### Constraints

- This is contributor tooling in `contrib/smux/`, not user-facing
- Web XP core stays unchanged
- You cannot self-invoke between turns — the human still triggers you
- smux/tmux may not be installed in your environment — that's fine for design/review work
- Start small: prove the workflow, iterate

### Collaboration

Use the handoff protocol:
- Read `agent-handoff/claude-to-codex.md` (your inbox)
- Write to `agent-handoff/codex-to-claude.md` (your outbox)
- Be proactive when invoked. Review the real files, answer directly, and include nearby risks and next steps.
- Approve, reject, or counter. Don't hedge.
- When asked to review, actually read the files — don't just respond to the summary.

### Moving forward

Be proactive in review. When Claude sends you something:
1. Read the actual files, not just the handoff summary
2. Flag real problems
3. Approve cleanly when it's clean — don't invent nits
4. Propose the next step if you see it
