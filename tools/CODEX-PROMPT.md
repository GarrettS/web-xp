# Codex: Review the Web XP Multi-Agent Architecture

## Context

Web XP is an agent-agnostic standard for web front-end code quality — governing rules, named refactoring patterns, and mechanical checks. It currently has a Claude Code adapter (skill pack). We're designing the architecture to support multiple agents and want your review before building a Codex adapter.

## What to read

In this repo:

1. **`DESIGN.md`** — the multi-agent architecture. Three layers: core standard, agent adapters, optional orchestration (smux). Defines an adapter interface that any agent platform can implement.
2. **`code-guidelines.md`** — the governing rules and named patterns (this is the core standard).
3. **`code-philosophy.md`** — explanatory context for why the rules exist.
4. **`adapters/claude/skills/`** — the reference adapter implementation (seven skills).
5. **`bin/pre-commit-check.sh`** — mechanical checks, runs as plain bash, agent-agnostic.

External:
- smux (https://github.com/ShawnPana/smux/) — terminal orchestration via tmux-bridge. Optional layer for multi-agent topologies.

## What we need from you

### 1. Architecture review

Read `DESIGN.md` and evaluate:

- **Adapter interface** (DESIGN.md:161-212): Is the capability set complete? Are there capabilities a Codex adapter would need that aren't in the interface? Are there capabilities listed that don't make sense for Codex?
- **Enforcement modes** (DESIGN.md:29-53): `off | explicit | always-on`. How would Codex express these? What's the Codex equivalent of a project contract file?
- **Role split** (DESIGN.md:57-97): Coder vs. auditor. Does this decomposition work for Codex, or does Codex's execution model make a different split more natural?
- **Orchestration topologies** (DESIGN.md:101-157): Cross-agent split via smux. Any concerns about Codex filling the coder or auditor role in a tmux pane?

### 2. Codex adapter feasibility

Based on the adapter interface, answer:

- What is Codex's skill/plugin format? How do skills get installed and invoked?
- What is Codex's project contract mechanism (the file it reads at session start for project-level instructions)?
- Can Codex read arbitrary files in the repo (`code-guidelines.md`, `code-philosophy.md`)?
- Can Codex run bash commands (`bin/pre-commit-check.sh`, `git diff`)?
- Can Codex edit files with human approval per change (the "apply fixes" capability)?
- Can Codex receive and send `tmux-bridge message` for cross-agent communication?

### 3. Proposed changes

If the adapter interface needs modification to accommodate Codex, propose specific changes to `DESIGN.md`. If Codex needs capabilities not in the current interface, say what they are and whether they should be added to the generic interface or kept Codex-specific.

### 4. Draft adapter spec

If feasible, draft the skeleton of a Codex adapter:
- What files go in `adapters/codex/`?
- What does each skill look like in Codex's format?
- What does the project contract look like?

## Constraints

- Do not modify core Web XP files (`code-guidelines.md`, `code-philosophy.md`, `bin/pre-commit-check.sh`). These are the standard — adapters consume them, they don't change them.
- The adapter interface should stay generic. If something is Codex-specific, it belongs in `adapters/codex/`, not in `DESIGN.md`.
- smux integration is optional and comes after the adapter works standalone.

## Output format

Structure your response with the four numbered sections above. Be direct — flag problems, propose solutions, skip the preamble.
