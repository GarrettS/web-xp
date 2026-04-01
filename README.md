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

## Install

Web XP is installed once per user, not per project. Both agents share the same install.

```bash
git clone https://github.com/GarrettS/web-xp.git ~/.web-xp
```

To update:

```bash
cd ~/.web-xp && git pull
```

## Agent Support

Web XP is agent-agnostic. The standard is the same regardless of which agent enforces it. Agent-specific adapters teach each platform how to load, check, review, and apply the standard.

| Agent | Implementation | Status |
|-------|----------------|--------|
| Claude Code | Native Agent Skills packaged to `.claude/skills/` | Implemented |
| Codex | Agent Skill spec files (`adapters/codex/`) | Implemented |

See [Architecture](#architecture) for the full design. To add support for another agent, see [Building a New Adapter](#building-a-new-adapter).

The same Web XP Agent Skills exist across agents. What changes is the packaging, not the intended behavior.

### Claude Code

After installing Web XP:

```bash
mkdir -p ~/.claude/skills
cp -r ~/.web-xp/.claude/skills/* ~/.claude/skills/
```

Then run `/web-xp-init` in your project to create a `CLAUDE.md` contract.

See `adapters/claude/README.md` for full details.

### Codex

After installing Web XP, in each project:

```bash
cp ~/.web-xp/adapters/codex/CODEX.example.md CODEX.md
```

In Codex, each Web XP Agent Skill is represented by a flat spec file in
`adapters/codex/` (`web-xp.md`, `web-xp-check.md`, etc.). These files are the
Codex equivalents of the Claude Agent Skill directories.

Point Codex to `CODEX.md` when starting a session. Invoke Agent Skills by spec file name (e.g. "follow `web-xp-check.md`").

See `adapters/codex/README.md` for full details.

### What Gets Installed

System install (`~/.web-xp`):

- full Web XP checkout
- adapter source and built contract templates
- Codex Agent Skill spec files in `adapters/codex/*.md`
- maintainer/build tooling used inside the Web XP checkout itself

Claude runtime/package install (`~/.claude/skills/`):

```bash
mkdir -p ~/.claude/skills
cp -r ~/.web-xp/.claude/skills/* ~/.claude/skills/
```

Codex runtime/package install:

- Codex reads the flat spec files directly from `~/.web-xp/adapters/codex/`

Project install:

- Claude Code projects: `CLAUDE.md`
- Codex projects: `CODEX.md`

### Project Footprint

Web XP's current project footprint is limited to the agent contract file (`CLAUDE.md` for Claude Code, `CODEX.md` for Codex).

Current behavior:

- `web-xp-init` creates the contract file by copying the built template if the
  file does not already exist
- if the contract file already exists, `web-xp-init` skips and does not merge
- `web-xp-on` / `web-xp-off` toggle the existing Web XP directives inside that
  file

This current behavior is intentionally documented as-is here. Changes to how
existing contract files are updated are tracked separately.

## Agent Skills

Seven Agent Skills, shared across all adapters. The skill names are the same regardless of agent.

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
| `web-xp-init` | Set up a new project with a contract file |
| `web-xp-on` | Enable always-on enforcement |
| `web-xp-off` | Disable enforcement |

How each Agent Skill is invoked depends on the agent:
- **Claude Code**: slash commands (`/web-xp`, `/web-xp-check`, etc.)
- **Codex**: reference the spec file by name (e.g. "follow `web-xp-check.md`")

## Enforcement Modes

Three states, orthogonal to which agent is running:

| Mode | Behavior |
|------|----------|
| **off** | Standards not loaded. No pre-commit checks. |
| **explicit** | Standards available on demand. User invokes Agent Skills manually. |
| **always-on** | Standards loaded every session. Checks required before every commit. |

Each adapter expresses these through its platform's project contract mechanism (`CLAUDE.md` for Claude, `CODEX.md` for Codex).

## Architecture

Web XP has three layers, each independent:

```
┌─────────────────────────────────────────────────┐
│  Agent Adapters                                 │
│  Claude · Codex · ...                           │
├─────────────────────────────────────────────────┤
│  Core Web XP                                    │
│  code-guidelines.md · code-philosophy.md        │
│  bin/pre-commit-check.sh                        │
└─────────────────────────────────────────────────┘
```

**Core** is the standard. It has no opinion about which agent runs it.
**Adapters** teach a specific agent how to use the standard. The adapter list is open. Authored adapter files live under `adapters/<platform>/`; platform-native runtime/package paths (for example `.claude/skills/`) are populated from that source as needed.

See `DESIGN.md` for the full architecture and role definitions.

### Project Contracts

Each agent's project contract is built from two sources:

1. **`AGENT.md`** — the shared base contract. Project-level rules that apply to every agent regardless of platform.
2. **`adapters/<agent>/overlay.md`** — agent-specific contract additions (platform config, invocation style, discovery paths).

`tools/build-contracts.sh` concatenates them to produce the built contract (e.g. `CLAUDE.example.md`, `CODEX.example.md`). Projects copy the built contract as their `CLAUDE.md` or `CODEX.md`.

From `tools/build-contracts.sh`:

```bash
# Because the build is plain concatenation (cat), anything in AGENT.md
# or overlay.md appears verbatim in the output. Do not put maintainer
# comments, build-chain docs, or internal notes in those files —
# they will leak into emitted project contracts.
```

```bash
build() {
  local overlay="$1" output="$2"
  local result
  result="$(cat "$AGENT" "$overlay")"
  ...
}
```

## Building a New Adapter

To add Web XP support for another agent platform:

1. Implement the four runtime Agent Skills and three setup Agent Skills in whatever format your platform uses.
2. Point all file references at the core files in the Web XP install (`code-guidelines.md`, `code-philosophy.md`, `bin/pre-commit-check.sh`).
3. Define a project contract mechanism that can express `off | explicit | always-on`.
4. Place adapter documentation and authored adapter files in `adapters/<platform>/`. If the platform requires a specific path for discovery, treat that path as generated/runtime packaging and document it in the adapter README.

## Workflow Strategy

For AI-assisted development under active human review. The standards constrain AI output and provide a shared vocabulary for correction and refactoring. They are most effective in the hands of an experienced developer who can recognize when the AI is structurally right, mechanically wrong, or conceptually off-base.

Each rule traces back to a specific failure observed during development. When the AI produces an anti-pattern, do not just fix the code. Tighten the rule so the failure is easier to catch the next time.

### Why the Pre-Commit Sequence Matters

> "The main thing that helps me see propagation is being told to look. The CLAUDE.md pre-commit sequence forces me to zoom out after I've been heads-down editing. Without that step, I'd mark the task done after the last edit." — Claude

## Disabling

Web XP enforcement is driven by your project's contract file (`CLAUDE.md` for Claude, `CODEX.md` for Codex). To disable it for a project, use `web-xp-off` (or manually comment out the directives). To re-enable, use `web-xp-on`. To disable globally, remove the adapter from your agent's configured skill/spec path.

## Removal

Two removal scopes exist today.

### Get It Out Of My Project

Current project removal is manual:

- delete `CLAUDE.md` or `CODEX.md` if Web XP is the only thing in the file
- or remove/comment out the Web XP directives if you want to keep the rest of
  the file

`web-xp-off` disables enforcement, but does not remove the file.

### Get It Off My System

Current system removal is also manual:

- remove the Web XP checkout:

```bash
rm -rf ~/.web-xp
```

- for Claude Code, also remove the copied Agent Skills from `~/.claude/skills/` if
  you previously installed them there

Web XP does not yet provide a dedicated cleanup/remove command.

## License

MIT
