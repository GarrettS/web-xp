# Web XP

### AI-Assisted XP for Lean, Transparent Web Front-End

Web XP gives you a shared doctrine, review workflow, and agent adapters for building on the web platform without losing architectural clarity as the project grows.

## Why Use It

AI writes code fast. Without constraints, it writes inconsistency and maintenance debt just as fast.

Web XP exists to keep speed from dissolving into slop. It applies shared standards, review discipline, and web-platform-first structure so code stays clear, debuggable, and durable as the project grows.

The point is not to recreate framework dependency in lighter clothing. Many framework abstractions solve problems introduced by the framework itself.

## What You Get

- **Governing standards** in `code-guidelines.md`: principles, named patterns, language rules, and formatting defaults
- **Explanatory context** in `code-philosophy.md`: why the standards work and what replaces common framework-era assumptions
- **Agent adapters** for Claude Code and Codex: load the standard, audit a diff, review arbitrary code, or walk through fixes interactively
- **Mechanical checks** in `bin/pre-commit-check.sh` for recurring violations such as inline handlers, hardcoded colors, loose equality, and junk-drawer filenames

## What It Covers

Concrete examples and reasoning live in `code-philosophy.md`, especially around:

- routing and URL-driven navigation
- state management and scope
- explicit initialization and data fetching
- failure handling and graceful degradation
- DOM ownership, dispatch, and CSS-driven state

If you want the operational rules and named patterns first, start with `code-guidelines.md`.

## Quick Start

Install Web XP once:

```bash
git clone https://github.com/GarrettS/web-xp.git ~/.web-xp
```

Update later with:

```bash
cd ~/.web-xp && git pull
```

### Claude Code

Install the Claude runtime files:

```bash
mkdir -p ~/.claude/skills
cp -r ~/.web-xp/.claude/skills/* ~/.claude/skills/
```

In a project, run:

```text
/web-xp-init
```

That creates or updates the Web XP-managed block in `CLAUDE.md`.

### Codex

In a project, create a `CODEX.md` contract from the Web XP template:

```bash
cp ~/.web-xp/adapters/codex/CODEX.example.md CODEX.md
```

Then point Codex to `CODEX.md` when starting a session.

## Project Activation

The global install makes Web XP available to the agent. The project contract activates Web XP behavior in a specific project.

- `CLAUDE.md` activates Web XP for Claude Code in that project
- `CODEX.md` activates Web XP for Codex in that project
- without a project contract, Web XP is still available globally, but usage is manual
- `web-xp-on` enables always-on behavior in that project
- `web-xp-off` disables enforcement in that project

Project mode is local to the project:

- **explicit**: Web XP is available on demand
- **always-on**: Web XP runs every session and before every commit
- **off**: Web XP stays inactive in that project

## Agent Skills

Web XP provides seven Agent Skills across adapters.

### Runtime

| Agent Skill | Role | Purpose |
|------------|------|---------|
| `web-xp` | both | Load the governing rules into the current session |
| `web-xp-check` | auditor | Read-only audit of the current diff |
| `web-xp-review` | auditor | Review any code against the standards |
| `web-xp-apply` | coder | Walk through findings one at a time with approval |

### Setup

| Agent Skill | Purpose |
|------------|---------|
| `web-xp-init` | Set up or update a project contract |
| `web-xp-on` | Enable always-on enforcement |
| `web-xp-off` | Disable enforcement |

How each Agent Skill is invoked depends on the agent:

- **Claude Code**: slash commands (`/web-xp`, `/web-xp-check`, etc.)
- **Codex**: reference the spec file by name (for example `web-xp-check.md`)

## What Gets Installed

System install (`~/.web-xp`):

- full Web XP checkout
- core doctrine files
- adapter source and built contract templates
- maintainer/build tooling used inside the Web XP checkout

Claude runtime/package install (`~/.claude/skills/`):

- generated Claude skill files copied from the Web XP checkout

Codex runtime/package install:

- Codex reads the flat spec files directly from `~/.web-xp/adapters/codex/`

Project footprint:

- Claude Code projects: `CLAUDE.md`
- Codex projects: `CODEX.md`
- the Web XP-managed block inside that project contract file

Current behavior:

- `web-xp-init` creates the contract file if it does not exist
- if the contract file already exists, `web-xp-init` inserts or replaces the Web XP-managed block and leaves surrounding content alone
- if the existing managed block has drift, `web-xp-init` warns and replaces it
- `web-xp-on` and `web-xp-off` toggle the Web XP directives inside the managed block only

## Update, Disable, and Remove

### Update

Update the global install:

```bash
cd ~/.web-xp && git pull
```

For Claude Code, re-copy the runtime files after updating:

```bash
cp -r ~/.web-xp/.claude/skills/* ~/.claude/skills/
```

### Disable

Disable Web XP in a project:

- use `web-xp-off`
- or manually comment out the Web XP directives inside the managed block

Re-enable it with `web-xp-on`.

### Remove From a Project

Current project removal is manual:

- remove the Web XP-managed block from `CLAUDE.md` or `CODEX.md`
- if the file exists only for Web XP, remove the file

### Remove From Your System

Current system removal is also manual:

```bash
rm -rf ~/.web-xp
```

For Claude Code, also remove the copied runtime files from `~/.claude/skills/` if you installed them there.

## Architecture

Web XP has two main parts:

- **Core Web XP**: `code-guidelines.md`, `code-philosophy.md`, and `bin/pre-commit-check.sh`
- **Agent adapters**: Claude, Codex, and future agents that apply the same standard in different packaging formats

Authored adapter files live under `adapters/<platform>/`. Platform-native runtime/package paths such as `.claude/skills/` are generated from that source as needed.

See `DESIGN.md` for the full architecture.

### Project Contracts

Each built project contract comes from two sources:

1. `AGENT.md` — the shared base contract
2. `adapters/<agent>/overlay.md` — agent-specific additions

`tools/build-contracts.sh` builds the emitted templates (for example `CLAUDE.example.md` and `CODEX.example.md`) from those sources.

## Adapter Details

Claude Code:

- native skill directories in `.claude/skills/`
- project contract in `CLAUDE.md`
- see `adapters/claude/README.md`

Codex:

- flat spec files in `adapters/codex/`
- project contract in `CODEX.md`
- see `adapters/codex/README.md`

## Building a New Adapter

To add Web XP support for another agent platform:

1. Implement the four runtime Agent Skills and three setup Agent Skills in that platform's format.
2. Point all file references at the core files in the Web XP install (`code-guidelines.md`, `code-philosophy.md`, `bin/pre-commit-check.sh`).
3. Define a project contract mechanism that can express `off | explicit | always-on`.
4. Place adapter documentation and authored adapter files in `adapters/<platform>/`. If the platform requires a specific discovery path, treat that path as generated/runtime packaging and document it in the adapter README.

## License

MIT
