# Web XP

### AI-Assisted XP for Lean, Transparent Web Front-End

Governing rules, named refactoring patterns, and review capabilities for building applications directly on the web platform. The code stays legible, stable, and maintainable as it grows.

Web XP takes the XP habits of tight feedback, simple design, and continuous refactoring and turns the dials up with AI-assisted review. The goal is not more generated code for its own sake. The goal is better code, produced faster, under active human judgment.

Kent Beck once asked, "What if we took all the good practices and turned the dials up to 11?" Web XP takes that instinct seriously on the web platform: AI tightens the feedback, review, and refactoring loops rather than replacing engineering judgment.

## Why It Exists

AI writes code fast. Without constraints, it writes inconsistency and maintenance debt just as fast.

Web XP exists to keep speed from dissolving into slop. It defines governing rules, reusable patterns, and review capabilities for applications built directly on the web platform, with an emphasis on code that remains clear, debuggable, and durable over time.

The point is not to recreate framework dependency in lighter clothing. Many framework abstractions solve problems introduced by the framework itself. Web XP keeps more of the system legible by working with the DOM and standardized Web APIs directly.

## What You Get

- **Governing standards** in `code-guidelines.md`: principles, named patterns, language rules, and formatting defaults.
- **Explanatory context** in `code-philosophy.md`: why the standards work, how framework-era assumptions weakened, and what replaces common abstractions.
- **Agent adapters** for Claude Code and Codex: load the standards, audit a diff, review arbitrary code, or walk through fixes interactively.
- **Mechanical checks** in `bin/pre-commit-check.sh` for recurring violations such as inline handlers, hardcoded colors, loose equality, and junk-drawer filenames.

## What It Covers

Web XP is not just style guidance. Its concrete examples live in `code-philosophy.md`, especially around:

- routing and URL-driven navigation
- state management and scope
- explicit initialization and data fetching
- failure handling and graceful degradation
- DOM ownership, dispatch, and CSS-driven state

If you want the argument and examples first, start with `code-philosophy.md`. If you want the operational rules and named patterns first, start with `code-guidelines.md`.

## Agent Support

Web XP is agent-agnostic. The standard is the same regardless of which agent enforces it. Agent-specific adapters teach each platform how to load, check, review, and apply the standard.

| Agent | Implementation | Status |
|-------|----------------|--------|
| Claude Code | Native skills (`.claude/skills/`) | Implemented |
| Codex | Capability spec files (`adapters/codex/`) | Implemented |

See [Architecture](#architecture) for the full design. To add support for another agent, see [Building a New Adapter](#building-a-new-adapter).

### Claude Code

First-time setup:

```bash
git clone https://github.com/GarrettS/web-xp.git ~/.claude/web-xp
mkdir -p ~/.claude/skills
cp -r ~/.claude/web-xp/.claude/skills/* ~/.claude/skills/
```

To update:

```bash
cd ~/.claude/web-xp && git pull
cp -r .claude/skills/* ~/.claude/skills/
```

Then run `/web-xp-init` in your project to create a `CLAUDE.md` contract and copy `pre-commit-check.sh`.

See `adapters/claude/README.md` for full details.

### Codex

First-time setup (spec file consumer):

```bash
git clone https://github.com/GarrettS/web-xp.git ~/.web-xp
cp ~/.web-xp/code-guidelines.md code-guidelines.md
cp ~/.web-xp/code-philosophy.md code-philosophy.md
mkdir -p bin
cp ~/.web-xp/bin/pre-commit-check.sh bin/pre-commit-check.sh
cp ~/.web-xp/adapters/codex/web-xp*.md .
cp ~/.web-xp/adapters/codex/AGENTS.skill.example.md AGENTS.md
```

Tell Codex to read `AGENTS.md` at the start of each session. Invoke capabilities by referencing the spec files (e.g. "follow `web-xp-check.md` to audit the current diff").

See `adapters/codex/README.md` for full details including submodule setup.

## Git Submodule

If you want the standards files present inside your own repository for direct references, pinned revisions, or project-specific standards work:

```bash
git submodule add https://github.com/GarrettS/web-xp.git .web-xp
```

The standards files and adapters live in `.web-xp/`. The hosting project records a specific standards commit.

To update a consuming project:

```bash
cd .web-xp
git pull origin main
cd ..
git add .web-xp
git commit -m "Update Web XP standards"
```

Note: `bin/check-web-xp-sync.sh` is internal to the Web XP repo — it auto-copies root standards files into `.claude/skills/` with DO NOT EDIT headers. Submodule consumers do not need it; the submodule pointer itself pins your standards version.

## Capabilities

Seven capabilities, shared across all adapters. The capability names are the same regardless of agent.

### Runtime

| Capability | Role | Purpose |
|------------|------|---------|
| `web-xp` | both | Load the governing rules into the current session |
| `web-xp-check` | auditor | Read-only audit of the current diff |
| `web-xp-review` | auditor | Review any code against the standards |
| `web-xp-apply` | coder | Walk through findings one at a time with approval |

### Setup

| Capability | Purpose |
|------------|---------|
| `web-xp-init` | Set up a new project with contract and pre-commit script |
| `web-xp-on` | Enable always-on enforcement |
| `web-xp-off` | Disable enforcement |

How each capability is invoked depends on the agent:
- **Claude Code**: slash commands (`/web-xp`, `/web-xp-check`, etc.)
- **Codex**: reference the spec file by name (e.g. "follow `web-xp-check.md`")

## Enforcement Modes

Three states, orthogonal to which agent is running:

| Mode | Behavior |
|------|----------|
| **off** | Standards not loaded. No pre-commit checks. |
| **explicit** | Standards available on demand. User invokes capabilities manually. |
| **always-on** | Standards loaded every session. Checks required before every commit. |

Each adapter expresses these through its platform's project contract mechanism (`CLAUDE.md` for Claude, `AGENTS.md` for Codex).

## Architecture

Web XP has three layers, each independent:

```
┌─────────────────────────────────────────────────┐
│  Orchestration (optional)                       │
│  smux · tmux-bridge · role assignment            │
├─────────────────────────────────────────────────┤
│  Agent Adapters                                 │
│  Claude · Codex · ...                           │
├─────────────────────────────────────────────────┤
│  Core Web XP                                    │
│  code-guidelines.md · code-philosophy.md        │
│  bin/pre-commit-check.sh                        │
└─────────────────────────────────────────────────┘
```

**Core** is the standard. It has no opinion about which agent runs it.
**Adapters** teach a specific agent how to use the standard. The adapter list is open. Some adapters keep authored files in a platform-native path (e.g. Claude skills in `.claude/skills/`); adapter documentation lives in `adapters/<platform>/`.
**Orchestration** coordinates multiple agents in different roles. Optional.

See `DESIGN.md` for the full architecture, role definitions, and orchestration topologies.

## Building a New Adapter

To add Web XP support for another agent platform:

1. Implement the four runtime capabilities and three setup capabilities in whatever format your platform uses.
2. Point all file references at the core files (`code-guidelines.md`, `code-philosophy.md`, `bin/pre-commit-check.sh`).
3. Define a project contract mechanism that can express `off | explicit | always-on`.
4. Place adapter documentation in `adapters/<platform>/`. If the platform requires a specific path for discovery, authored files may live there instead — document the path in the adapter README.

## Workflow Strategy

For AI-assisted development under active human review. The standards constrain AI output and provide a shared vocabulary for correction and refactoring. They are most effective in the hands of an experienced developer who can recognize when the AI is structurally right, mechanically wrong, or conceptually off-base.

Each rule traces back to a specific failure observed during development. When the AI produces an anti-pattern, do not just fix the code. Tighten the rule so the failure is easier to catch the next time.

### Why the Pre-Commit Sequence Matters

> "The main thing that helps me see propagation is being told to look. The CLAUDE.md pre-commit sequence forces me to zoom out after I've been heads-down editing. Without that step, I'd mark the task done after the last edit." — Claude

## Canonical Workflow

This repository is the canonical source for Web XP.

When changing Web XP itself:

1. Edit and commit in a working clone of `web-xp`.
2. Push the change to the canonical GitHub repository.
3. Update any consuming project that vendors the standards as a submodule.
4. Commit the submodule pointer update in that parent project separately.

Changing the standards and updating a consuming project to use that change are separate repository changes.

## Disabling

Web XP enforcement is driven by your project's contract file (`CLAUDE.md` for Claude, `AGENTS.md` for Codex). To disable it for a project, use `web-xp-off` (or manually comment out the directives). To re-enable, use `web-xp-on`. To disable globally, remove the adapter from your agent's skill/spec path.

## License

MIT
