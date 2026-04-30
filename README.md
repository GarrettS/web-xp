# Web XP

[![License: MIT](https://img.shields.io/github/license/GarrettS/web-xp.svg)](LICENSE)
[![Open issues](https://img.shields.io/github/issues/GarrettS/web-xp.svg)](https://github.com/GarrettS/web-xp/issues)
[![Contributors](https://img.shields.io/github/contributors/GarrettS/web-xp.svg)](https://github.com/GarrettS/web-xp/graphs/contributors)
[![Last commit](https://img.shields.io/github/last-commit/GarrettS/web-xp.svg)](https://github.com/GarrettS/web-xp/commits/main)

### AI-Assisted XP for Lean, Transparent Web Front-End

Web XP gives you a shared doctrine, review workflow, and agent adapters for building on the web platform without losing architectural clarity as the project grows.

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

In a project, run:—

```text
/web-xp-on
```
— to create or update `CLAUDE.md` in the current project.

### Codex

In Codex, `web-xp-on` (no slash) creates or updates `CODEX.md` in the current project.

Alternatively, you can bootstrap Web XP directly from the shell:

```bash
~/.web-xp/bin/web-xp-on claude
~/.web-xp/bin/web-xp-on codex
```

## Why Use It

AI writes code fast. Without constraints, it writes inconsistency and maintenance debt just as fast.

Web XP exists to keep speed from dissolving into slop. It applies shared standards, review discipline, and web-platform-first structure so code stays clear, debuggable, and durable as the project grows.

### What you get

After install, here is what is on your system and what each piece does:

```
~/.web-xp/                          ← system install (git clone + install.sh)
├── code-guidelines.md              ← the doctrine
├── code-philosophy.md              ← why the doctrine works
├── bin/pre-commit-check.sh         ← mechanical checks
├── bin/web-xp-on                 ← shell bootstrap plumbing
├── bin/web-xp-off                  ← shell project cleanup command
├── bin/web-xp-off                  ← shell cleanup
├── adapters/claude/                ← Claude skill source + overlay
│   └── CLAUDE.example.md           ← built template
└── adapters/codex/                 ← Codex skill source + overlay
    ├── skills/                     ← built Codex skills
    └── CODEX.example.md            ← built template

~/.claude/skills/                   ← Claude runtime (install.sh copies here)
$HOME/.agents/skills/               ← Codex runtime (install.sh copies here)

your-project/
├── CLAUDE.md or CODEX.md           ← project contract
└── prd/project.md (optional)       ← your project overlay
```

**`code-guidelines.md`** is the doctrine — principles, named patterns, language rules, and formatting defaults. Agents consume it as session constraints. Users read it to understand what the standard requires.

**`code-philosophy.md`** explains why the standards work and what replaces common framework-era assumptions. It is useful for users who want the reasoning, and for implementers and maintainers who need to understand design decisions.

**`bin/pre-commit-check.sh`** catches mechanical violations — inline handlers, hardcoded colors, loose equality, junk-drawer filenames. It runs before every commit in always-on mode.

> "The main thing that helps me see propagation is being told to look. The CLAUDE.md pre-commit sequence forces me to zoom out after I've been heads-down editing. Without that step, I'd mark the task done after the last edit." — Claude

**Agent adapters** package the same standard for different agents. Claude and Codex both use discovered skill directories. The skills are the same — the discovery roots and contract files differ.

## Project Activation

The global install makes Web XP available to the agent. The project contract activates Web XP behavior in a specific project.

- `CLAUDE.md` activates Web XP for Claude Code in that project
- `CODEX.md` activates Web XP for Codex in that project
- without a project contract, Web XP is still available globally, but usage is manual
- `web-xp-on` creates or updates the project contract and enables always-on behavior
- `web-xp-off` removes the project contract block and disables enforcement

Project mode is local to the project:

- **explicit**: Web XP is available on demand
- **always-on**: Web XP runs every session and before every commit
- **off**: Web XP stays inactive in that project

| Skill | What it does |
|---|---|
| `web-xp-on` | Create or update the project contract and enable enforcement |
| `web-xp-off` | Remove Web XP from the current project contract |

## Session Skills

Session skills are for evaluating Web XP or for one-off code checks. They load the standards into the current conversation but do not modify `CLAUDE.md` or `CODEX.md`. Without a project contract, that guidance is session-scoped: it is not automatically reloaded in later sessions, and it is easier for the standards to fall out of focus as the conversation grows. Running `web-xp-on` creates or updates a project contract, which gives the agent a more consistent enforcement path across sessions and commits.

| Skill | Role | What it does |
|---|---|---|
| `web-xp` | both | Load the governing rules into this session |
| `web-xp-check` | auditor | Audit the current diff |
| `web-xp-review` | auditor + coder | Review any code against the standards; apply fixes only on explicit request or approval |

## Project Overlay

Web XP's standards are canonical. Project-specific decisions such as directory structure, asset strategy, content authority, typography, and viewport floor live in a separate **project overlay** file, not in a fork of the standards.

A project overlay is your project's own file — for example `prd/project.md`. Its rules cascade over the standard's defaults: overriding ("except here, because..."), extending ("in addition to that..."), or specializing ("and for this project..."). The [PRI Pelvis Restoration study tool](https://github.com/GarrettS/pelvis) uses `prd/project.md` as its overlay:

```
## Content Authority
- Pelvis Restoration 2026 Complete Manual.md — authoritative for all
  PRI content. If app data contradicts the manual, the manual wins.

## Key Decisions
- Hash-based SPA navigation (location.hash + hashchange). No History API.
- JSON data files in data/.
- sw.js lives at project root (browser scope constraint).
```

The overlay covers things like:
- content authority (which source wins when data conflicts)
- key architecture decisions (routing strategy, data format, service worker placement)
- directory layout and asset rules
- design references (style guides, PRDs, feature specs)

## Update, Disable, and Remove

### Update

Update the global install:

```bash
git -C ~/.web-xp pull && ~/.web-xp/bin/install.sh
```

### Disable

Disable Web XP in a project:

- use `web-xp-off`
- or manually remove the Web XP-managed block from the contract file

Re-enable it with `web-xp-on`.

### Remove From a Project

Project removal:

```bash
~/.web-xp/bin/web-xp-off
```

That removes the Web XP-managed block from `CLAUDE.md` and `CODEX.md` in the current project, and deletes either file if it only contains Web XP.

### Remove From Your System

```bash
~/.web-xp/bin/uninstall.sh
```

## Architecture

Web XP uses an adapter pattern: one standard, nearly the same interface across agents. Claude uses `/web-xp-check`, Codex uses `web-xp-check` — the behavior and output differ, but the skills are the same.

Each agent does things differently. This creates interesting workflow possibilities: swap agents for different tasks, use one agent to review another's work, or fall back to a different agent when one is down — all under the same standard.

For the full architecture — enforcement modes, roles, adapter interface, orchestration topologies — see `DESIGN.md`. To build a new adapter or understand the build chain, see `MAINTAINERS.md`.

## License

MIT
