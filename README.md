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

### Why the Pre-Commit Sequence Matters

> "The main thing that helps me see propagation is being told to look. The CLAUDE.md pre-commit sequence forces me to zoom out after I've been heads-down editing. Without that step, I'd mark the task done after the last edit." — Claude

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
git clone https://github.com/GarrettS/web-xp.git ~/.web-xp && ~/.web-xp/bin/install.sh
```

Update later with:

```bash
git -C ~/.web-xp pull && ~/.web-xp/bin/install.sh
```

### Claude Code

In a project, run:

```text
/web-xp-init
```

That creates or updates `CLAUDE.md` in the current project.

### Codex

In Codex, run:

```text
web-xp-init
```

That creates or updates `CODEX.md` in the current project.

You can also bootstrap directly from the shell:

```bash
~/.web-xp/bin/web-xp-init claude
~/.web-xp/bin/web-xp-init codex
```

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
| `web-xp-remove` | Remove Web XP from the current project |

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
- install also copies the Codex setup skills to:
  - `~/.codex/skills/web-xp-init/`
  - `~/.codex/skills/web-xp-remove/`

Project footprint:

- Claude Code projects: `CLAUDE.md`
- Codex projects: `CODEX.md`
- the Web XP-managed block inside that project contract file

Current behavior:

- `web-xp-init` creates the contract file if it does not exist
- if the contract file already exists, `web-xp-init` inserts or replaces the Web XP-managed block and leaves surrounding content alone
- if the existing managed block has drift, `web-xp-init` warns and replaces it
- `web-xp-on` and `web-xp-off` toggle the Web XP directives inside the managed block only

## Project Overlay

Web XP's standards are canonical. Project-specific decisions such as directory structure, asset strategy, content authority, typography, and viewport floor live in a separate **project overlay** file, not in a fork of the standards.

A project overlay is your project's own file — for example `prd/project.md`. It states what the project is and records the decisions that belong to that project rather than to Web XP itself. The [PRI Pelvis Restoration study tool](https://github.com/GarrettS/pelvis) uses `prd/project.md` as its overlay:

```
## Code Standards
This project follows Web XP, installed at ~/.web-xp/:
- ~/.web-xp/code-guidelines.md — what the code looks like
- ~/.web-xp/code-philosophy.md — why the standards are structured this way

This file (project.md) is the project overlay. Project-specific
decisions live here, not in a fork of the standards.
```

The overlay covers things like:
- directory layout and asset rules
- content authority (which source wins when data conflicts)
- key architecture decisions (routing strategy, data format, service worker placement)
- design references (style guides, PRDs, feature specs)

Currently the overlay is documentation. It helps keep project-specific decisions out of forks of the standard.

## Update, Disable, and Remove

### Update

Update the global install:

```bash
git -C ~/.web-xp pull && ~/.web-xp/bin/install.sh
```

### Disable

Disable Web XP in a project:

- use `web-xp-off`
- or manually comment out the Web XP directives inside the managed block

Re-enable it with `web-xp-on`.

### Remove From a Project

Project removal:

```bash
~/.web-xp/bin/web-xp-remove
```

That removes the Web XP-managed block from `CLAUDE.md` and `CODEX.md` in the current project, and deletes either file if it only contains Web XP.

### Remove From Your System

Current system removal is also manual:

```bash
rm -rf ~/.web-xp
```

For Claude Code, also remove the copied runtime files from `~/.claude/skills/` if you installed them there.

## Architecture

The standard is one thing. The packaging is per-agent. Web XP uses an adapter pattern so the same seven skills work the same way regardless of which agent runs them — Claude, Codex, or whatever comes next. Because the standard is vendor-agnostic, teams can mix agents, swap agents, or have agents review each other's work without changing the methodology.

### How it fits together

```
~/.web-xp/                          ← system install (git clone + install.sh)
├── code-guidelines.md              ← the doctrine
├── code-philosophy.md              ← why the doctrine works
├── bin/pre-commit-check.sh         ← mechanical checks
├── bin/web-xp-init                 ← shell bootstrap fallback
├── bin/web-xp-remove               ← shell project cleanup fallback
├── adapters/claude/                ← Claude skill source + overlay
│   └── CLAUDE.example.md           ← built template
└── adapters/codex/                 ← Codex spec files + overlay
    └── CODEX.example.md            ← built template

~/.claude/skills/                   ← Claude runtime (install.sh copies here)
~/.codex/skills/                    ← Codex setup skills (install.sh copies here)

your-project/
├── CLAUDE.md or CODEX.md           ← project contract
└── prd/project.md (optional)       ← your project overlay
```

**System install** (`git clone + install.sh`): clones `~/.web-xp`, copies Claude skills to `~/.claude/skills/`, installs the Codex setup skills to `~/.codex/skills/`, and makes the shell bootstrap/remove fallbacks available at `~/.web-xp/bin/`.

**Project setup**:
- **Shell fallback**: `~/.web-xp/bin/web-xp-init claude|codex|all` creates or updates the project contract(s).
- **Claude**: `/web-xp-init` creates or updates `CLAUDE.md` with the Web XP-managed block.
- **Codex**: `web-xp-init` creates or updates `CODEX.md`, then Codex reads that project contract.

**Project cleanup**:
- **Shell fallback**: `~/.web-xp/bin/web-xp-remove claude|codex|all` removes Web XP from the project contract(s).
- **Claude**: `/web-xp-remove` removes Web XP from `CLAUDE.md`.
- **Codex**: `web-xp-remove` removes Web XP from `CODEX.md`.

To build a new adapter or understand the build chain, see `MAINTAINERS.md`.

## License

MIT
