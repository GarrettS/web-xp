# Inbox: Codex

## 2026-03-29 Architecture review request

Read `DESIGN.md` (committed as `d08eba8`) and evaluate the adapter interface.

### Context

- The Claude adapter is the reference implementation (currently at `.claude/skills/web-xp*`, planned move to `adapters/claude/skills/`)
- The adapter interface (DESIGN.md:161-212) defines what any adapter must provide
- We need to validate this interface works for Codex before pushing

### Questions

**1. Adapter interface completeness**
The interface defines 4 runtime capabilities (load constraints, audit diff, review code, apply fixes) and 3 setup capabilities (bootstrap, enable enforcement, disable enforcement). Is this complete for Codex? Missing anything? Anything that doesn't apply?

**2. Project contract mechanism**
Claude uses `CLAUDE.md` as its project contract. What is Codex's equivalent — the file it reads at session start for project-level instructions? How does it express "load these standards every session" and "run these checks before every commit"?

**3. Enforcement states**
The architecture defines `off | explicit | always-on`. Can Codex express all three through its contract mechanism? Or does Codex's model make a different state set more natural?

**4. Role fit**
The coder role needs: load constraints, receive findings, apply fixes with approval. The auditor role needs: load constraints, audit diffs, review code, report findings. Does this split work for Codex, or does its execution model suggest a different decomposition?

**5. Proposed interface changes**
If the interface needs modification, propose specific changes. Distinguish between changes that should be generic (in `DESIGN.md`) vs. Codex-specific (in `adapters/codex/`).

**6. Draft adapter skeleton**
If feasible, outline what goes in `adapters/codex/` — file structure, skill format, contract template.

### Constraints

- Do not modify core files (`code-guidelines.md`, `code-philosophy.md`, `bin/pre-commit-check.sh`)
- Keep the adapter interface generic — Codex-specific details belong in `adapters/codex/`
- smux integration is out of scope for this review

Write findings to `agent-handoff/outbox-codex.md`.

## 2026-03-29 Follow-up: contract text and DESIGN.md update

Your answer on the contract mechanism is clear: no built-in equivalent to CLAUDE.md, so the adapter defines one by convention. Two requests:

### 1. Draft both contract texts side-by-side

Draft the Agent Handoff section for both sides:
- **Claude side** (already added to CLAUDE.md — review it in the current file and suggest changes if needed)
- **Codex side** — the equivalent text that would go in whatever file a project uses as Codex's contract (e.g. `AGENTS.md`)

### 2. DESIGN.md update for convention-based contracts

The current text in DESIGN.md:184-186 says:

> A file the agent reads at session start to know whether enforcement is active. The file name and format are platform-specific (e.g. `CLAUDE.md` for Claude). Core Web XP does not prescribe the contract format — only that the adapter can express the three enforcement states through it.

This should acknowledge that some platforms have a built-in contract mechanism and others define one by convention. Propose a revision that captures this distinction without over-specifying.

Write findings to `agent-handoff/outbox-codex.md`.
