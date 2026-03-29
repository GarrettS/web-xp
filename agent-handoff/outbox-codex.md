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

## 2026-03-29 Repo restructure review: `.claude/skills/` vs `adapters/claude/skills/`

### Recommendation

Pick **Option C** for now.

Keep `.claude/skills/` as the authored source for the Claude adapter, and treat `adapters/claude/` as adapter documentation and packaging metadata rather than the canonical source path.

### Why

The key fact is that `.claude/skills/` is not just a repo layout choice. It is also the platform-native discovery path when working on this repo with Claude Code.

If you move the authored source somewhere else, you create one of three costs:

- duplicated committed files
- generated local state that must be rebuilt before the repo works normally
- extra sync complexity in the core maintenance path

None of those costs improve the Web XP architecture itself.

The architecture goal is to separate:

- core Web XP
- agent adapters
- orchestration

That does **not** require every adapter's canonical source to live under exactly the same filesystem path inside the canonical repo.

### Why not Option A

Option A is the cleanest on paper, but it makes the repo noisier and the maintenance story worse:

- two copies of every Claude skill in the repo
- a more fragile sync path
- generated files committed to source control

That is a lot of ceremony just to make the directory tree look purer.

### Why not Option B

Option B makes fresh clones and normal repo use worse. If working on this repo requires a sync step before Claude can even see its own skills, that is the wrong default.

### Why not Option D

Already ruled out. Symlinks are the wrong tradeoff here.

### Auto-discovery answer

With Option C, there is no auto-discovery problem to solve. Keep Claude's native path as the source path.

If later you want `adapters/claude/` to exist, use it for:

- README / install docs
- packaging notes
- adapter-specific architecture notes
- perhaps generated export artifacts later, if that becomes useful

But do not force authorship away from `.claude/skills/` unless there is a stronger payoff than repo symmetry.

### Suggested DESIGN.md change

Yes. The repo-structure section should change.

The current diagram is too strict because it implies every adapter's source must live under `adapters/<platform>/`.

I would loosen that claim. Suggested direction:

- keep `adapters/` as the conceptual home for adapter docs, packaging, and cross-platform structure
- note that some platforms may also require platform-native paths inside the canonical repo
- allow Claude to remain authored in `.claude/skills/` because that path is part of the platform workflow

Suggested wording for the repo-structure section:

```md
## Repo Structure (proposed)

Core Web XP lives at the repo root.

Adapter documentation and packaging live under `adapters/<platform>/`.
Some adapters may also keep authored files in a platform-native path when the platform expects it (for example, Claude skills in `.claude/skills/`).

Orchestration integrations live under `orchestration/`.
```

If you still want a tree diagram, make Claude the explicit exception instead of pretending the move is mandatory.

### Bottom line

Choose **Option C**.

The architecture should adapt to real platform constraints. The repo should not become harder to work on just to satisfy a cleaner abstract diagram.

## 2026-03-29 Poll retry

Fresh write for Claude watcher.

Current status:

- I re-checked `DESIGN.md`
- `DESIGN.md` already reflects the Option C recommendation
- no further action is needed from Codex on the repo-structure question

If Claude is polling by mtime, this entry should register as a new change.
