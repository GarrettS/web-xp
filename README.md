# Web XP

### AI-Assisted XP for Lean, Transparent Web Front-End

Web XP gives you a shared doctrine, review workflow, and agent adapters for building on the web platform without losing architectural clarity as the project grows.

## Why Use It

AI writes code fast. Without constraints, it writes inconsistency and maintenance debt just as fast.

Web XP exists to keep speed from dissolving into slop. It applies shared standards, review discipline, and web-platform-first structure so code stays clear, debuggable, and durable as the project grows.

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

### What you get

After install, here is what is on your system and what each piece does:

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

**`code-guidelines.md`** is the doctrine — principles, named patterns, language rules, and formatting defaults. Agents consume it as session constraints. Users read it to understand what the standard requires.

**`code-philosophy.md`** explains why the standards work and what replaces common framework-era assumptions. It is useful for users who want the reasoning, and for implementers and maintainers who need to understand design decisions.

**`bin/pre-commit-check.sh`** catches mechanical violations — inline handlers, hardcoded colors, loose equality, junk-drawer filenames. It runs before every commit in always-on mode.

> "The main thing that helps me see propagation is being told to look. The CLAUDE.md pre-commit sequence forces me to zoom out after I've been heads-down editing. Without that step, I'd mark the task done after the last edit." — Claude

**Agent adapters** package the same standard for different agents. Claude uses native skill directories. Codex uses flat spec files. The skills are the same — the packaging differs.

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

| Skill | What it does |
|---|---|
| `web-xp-init` | Create or update the project contract |
| `web-xp-on` | Enable always-on enforcement |
| `web-xp-off` | Disable enforcement |
| `web-xp-remove` | Remove Web XP from the current project |

## Session Skills

Session skills are for evaluating Web XP or for one-off code checks. They load the standards into the current conversation but do not modify `CLAUDE.md` or `CODEX.md`. Without a project contract, that guidance is session-scoped: it is not automatically reloaded in later sessions, and it is easier for the standards to fall out of focus as the conversation grows. Running `web-xp-init` creates a project contract, which gives the agent a more consistent enforcement path across sessions and commits.

| Skill | Role | What it does |
|---|---|---|
| `web-xp` | both | Load the governing rules into this session |
| `web-xp-check` | auditor | Audit the current diff |
| `web-xp-review` | auditor | Review any code against the standards |
| `web-xp-apply` | coder | Walk through fixes one at a time with approval |

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
- or manually comment out the Web XP directives inside the managed block

Re-enable it with `web-xp-on`.

### Remove From a Project

Project removal:

```bash
~/.web-xp/bin/web-xp-remove
```

That removes the Web XP-managed block from `CLAUDE.md` and `CODEX.md` in the current project, and deletes either file if it only contains Web XP.

### Remove From Your System

```bash
rm -rf ~/.web-xp ~/.claude/skills/web-xp* ~/.codex/skills/web-xp*
```

## Architecture

Web XP uses an adapter pattern: one standard, nearly the same interface across agents. Claude uses `/web-xp-check`, Codex uses `web-xp-check` — the behavior and output differ, but the skills are the same.

Each agent does things differently. This creates interesting workflow possibilities: swap agents for different tasks, use one agent to review another's work, or fall back to a different agent when one is down — all under the same standard.

For the full architecture — enforcement modes, roles, adapter interface, orchestration topologies — see `DESIGN.md`. To build a new adapter or understand the build chain, see `MAINTAINERS.md`.

## License

MIT
