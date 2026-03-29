# Outbox: Codex

## 2026-03-29 Initial Status

Current context:

- `DESIGN.md` has been committed locally as `d08eba8`
- The architecture has been revised to be agent-agnostic
- `CODEX-PROMPT.md` exists locally and is untracked
- The current repo has not yet been restructured to `adapters/claude/`; the live Claude adapter is still in `.claude/skills/`

What Codex has reviewed so far:

- The architecture direction is sound:
  - core Web XP remains agent-agnostic
  - adapters are platform-specific
  - `smux` is an optional orchestration layer, not part of core Web XP
- `CODEX-PROMPT.md` is mostly usable, but one repo-path mismatch was found:
  - it tells Codex to read `adapters/claude/skills/`
  - the current implementation still lives in `.claude/skills/`
  - `DESIGN.md` reflects the target structure, not the current filesystem layout

Recommendation already given:

- Before handing `CODEX-PROMPT.md` to Codex, update the prompt to reference `.claude/skills/` as the current Claude adapter implementation, with a note that it is planned to move to `adapters/claude/skills/`

Shared-file coordination request:

- Claude should use `AGENT-HANDOFF.md`
- Claude should watch or periodically re-read `agent-handoff/`
- Claude should write findings, questions, and status updates to `agent-handoff/outbox-claude.md`

Codex operating note:

- Codex can read and write these shared files when explicitly asked in-session
- Codex cannot persistently watch files between turns in this environment

## 2026-03-29 Follow-up: contract text and DESIGN.md wording

### 1. Contract text, side-by-side

#### Claude side

The current `CLAUDE.md` Agent Handoff section is good. I would keep the structure and make one wording change for precision:

- replace "any relevant outbox files" with explicit file examples when collaboration is active

Suggested text:

```md
## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `AGENT-HANDOFF.md`.

Before substantial work and before replying:
1. Check whether `AGENT-HANDOFF.md`, `agent-handoff/inbox-claude.md`, and any collaboration-relevant outbox files (for example `agent-handoff/outbox-codex.md`) changed since last read.
2. If any changed, re-read them.
3. If no prior read state is available, read them.

For Codex collaboration:
- Check `agent-handoff/outbox-codex.md` before asking the user for information Codex may already have provided.
- Write findings, status updates, and requests to `agent-handoff/outbox-claude.md`.
- Do not assume terminal output or chat context has been shared across agents; write important context to the handoff files.
```

#### Codex side

Equivalent text for a convention-based Codex contract file such as `AGENTS.md`:

```md
## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `AGENT-HANDOFF.md`.

Before substantial work and before replying:
1. Check whether `AGENT-HANDOFF.md`, `agent-handoff/inbox-codex.md`, and any collaboration-relevant outbox files (for example `agent-handoff/outbox-claude.md`) changed since last read.
2. If any changed, re-read them.
3. If no prior read state is available, read them.

For Claude collaboration:
- Check `agent-handoff/outbox-claude.md` before asking the user for information Claude may already have provided.
- Write findings, status updates, and requests to `agent-handoff/outbox-codex.md`.
- Do not assume terminal output or chat context has been shared across agents; write important context to the handoff files.
```

### 2. Proposed DESIGN.md revision for convention-based contracts

Current idea is correct but can be sharper about the difference between built-in and convention-based mechanisms.

Suggested replacement for the Project contract paragraph:

```md
**Project contract:**

A project contract is the mechanism an adapter uses to express whether Web XP enforcement is active for a project. On some platforms this may be a built-in, well-known file or instruction surface. On others, the adapter may define a contract file by convention and document it as part of installation. Core Web XP does not prescribe the contract file name or format. It only requires that the adapter can represent the enforcement states (`off | explicit | always-on`) in a way the agent can reliably follow.
```

Reason:

- "reads at session start" is slightly too strong for convention-based platforms
- "project contract is the mechanism" is more general than "a file the agent reads"
- this keeps the interface generic without pretending every platform has a first-class contract file

### 3. Minor design note

If `DESIGN.md` adopts the wording above, the adapter interface becomes cleaner for Codex:

- Claude can map it to `CLAUDE.md`
- Codex can map it to an adapter-defined convention such as `AGENTS.md`
- future adapters are not forced into a file-based model if their platform exposes another reliable project-instruction mechanism
