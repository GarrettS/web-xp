# Web XP — Multi-Agent Architecture

## Overview

Web XP is an agent-agnostic standard for web front-end code quality. It defines governing rules, named refactoring patterns, and mechanical checks that any coding agent can enforce — not just Claude.

The system has three layers, each independent:

```
┌─────────────────────────────────────────────────┐
│  Agent Adapters                                 │
│  adapters/claude · adapters/codex · ...         │
├─────────────────────────────────────────────────┤
│  Core Web XP                                    │
│  code-guidelines.md · code-philosophy.md        │
│  bin/pre-commit-check.sh                        │
└─────────────────────────────────────────────────┘
```

**Core** is the standard. It has no opinion about which agent runs it.
**Adapters** teach a specific agent how to load, check, review, and apply the standard. The adapter list is open — anyone can add one for their platform.

---

## Enforcement Modes

Three architectural states. Orthogonal to which agent is running.

### Internal states

| State | Behavior |
|-------|----------|
| **off** | Standards not loaded. No pre-commit checks. |
| **explicit** | Standards available on demand. User invokes check/review manually. |
| **always-on** | Standards loaded every session. Checks required before every commit. |

### How states map to the current surface

| State | Project contract | User action |
|-------|-----------------|-------------|
| **off** | Directives commented out | `/web-xp-off` (Claude) |
| **explicit** | No directives present | No command — this is the default before `/web-xp-init` |
| **always-on** | Active directives | `/web-xp-on` (Claude) |

`explicit` is not a command — it is the state a project is in before any contract is written, or after directives are removed entirely. The current `/web-xp-on` and `/web-xp-off` commands toggle between `off` and `always-on` only. Whether `explicit` needs its own command is an open question; for now it does not, because a project without a contract is already in explicit mode.

### Agent contract mechanisms

Each adapter implements these states through its platform's project contract mechanism (e.g. `CLAUDE.md` for Claude). The contract file and its format are adapter-specific — core Web XP does not prescribe them.

---

## Roles

Two runtime roles. Any agent can fill either role. The role determines which capabilities the agent needs at coding time.

Both roles require **load constraints** — every agent in the workflow must internalize the standard before writing or reviewing code.

### Coder

The agent writing and modifying source code.

**Runtime capabilities:**
- **Load constraints** — internalize the standard before writing code
- **Receive findings** — read audit results (from self or another agent)
- **Apply fixes** — edit source files to resolve violations, with human approval

**What the coder does NOT do:**
- Run read-only audits (that's the auditor's job in multi-agent mode)
- Make the final quality judgment on its own changes

### Auditor

The agent reviewing code against the standard.

**Runtime capabilities:**
- **Load constraints** — internalize the standard before reviewing
- **Audit diffs** — read `git diff`, run mechanical checks, identify pattern violations and opportunities
- **Review arbitrary code** — evaluate pasted snippets, files, or directories against the standard
- **Report findings** — structured output: file, line, pattern name, violation/opportunity, alternative

**What the auditor does NOT do:**
- Edit source files
- Apply fixes (it reports; the coder applies)

### Project setup (not a runtime role)

These capabilities are administrative — used during project setup, not during the code/audit loop:

- **Bootstrap** — set up a new project with a contract file
- **Toggle enforcement** — switch between off and always-on

In single-agent mode, the same agent handles setup and runtime. In multi-agent mode, setup is a human decision made before agents start working.

---

## Orchestration Topologies

Three topologies. Only the first is implemented. The others are planned and depend on smux (not yet built).

### Single-agent (default)

One agent fills both roles. This is the current Web XP workflow.

```
┌──────────────┐
│  Agent       │
│  coder +     │
│  auditor     │
│              │
│  writes code │
│  checks own  │
│  diff        │
└──────────────┘
```

No orchestration layer needed. The agent loads constraints, writes code, runs checks before commit, applies fixes. One agent uses both coder and auditor skills. Setup skills (`web-xp-init`, `web-xp-on`, `web-xp-off`) are used at project configuration time, not during the normal code/audit loop.

### Split: one codes, one audits

Two agents in separate panes. One writes code, the other reviews. The auditor sends findings to the coder via `tmux-bridge message`.

```
┌──────────────┐     tmux-bridge      ┌──────────────┐
│  Coder       │ ◄──── findings ───── │  Auditor     │
│              │                      │              │
│  writes code │ ───── diffs ───────► │  reads diffs │
│  applies     │                      │  runs checks │
│  fixes       │                      │  reports     │
└──────────────┘                      └──────────────┘
```

The split topology is for cross-agent orchestration — the value comes from having a different agent audit than the one that wrote the code. Same-agent split is technically possible but offers no review independence over single-agent mode.

Any two agents with Web XP adapters can fill the coder and auditor roles. The topology is defined by role assignment, not agent identity:

| Role | Filled by |
|------|-----------|
| Coder | Any agent with the coder capability set |
| Auditor | Any agent with the auditor capability set |

### Continuous audit loop

Same as split, but the auditor runs on an interval. It watches for changes and messages the coder only when violations appear.

```
┌──────────────┐                      ┌──────────────┐
│  Coder       │ ◄── findings ─────── │  Auditor     │
│              │     (only when       │  (on timer)  │
│  writes code │      violations      │  polls diff  │
│              │      found)          │  runs checks │
└──────────────┘                      └──────────────┘
```

---

## Agent Adapter Interface

An adapter teaches one agent platform how to use Web XP. Any agent that can read files and run bash commands can have an adapter. The adapter list is open.

### What an adapter must provide

**Runtime skills (or equivalent):**

| Capability | Role | What it does |
|------------|------|--------------|
| Load constraints | both | Read `code-guidelines.md` and `code-philosophy.md`, apply as session constraints |
| Audit diff | auditor | Read `git diff`, run `bin/pre-commit-check.sh`, report pattern violations and opportunities |
| Review code | auditor | Evaluate arbitrary code (pasted, file path, directory) against the standard |
| Apply fixes | coder | Edit source files to resolve violations, with human approval per change |

**Setup skills (or equivalent):**

| Capability | What it does |
|------------|--------------|
| Bootstrap | Create a project contract file |
| Enable enforcement | Activate always-on directives in the project contract |
| Disable enforcement | Deactivate directives (preserving them for re-enable) |

**Project contract:**

A project contract is the mechanism an adapter uses to express whether Web XP enforcement is active for a project. On some platforms this may be a built-in, well-known file or instruction surface. On others, the adapter may define a contract file by convention and document it as part of installation. Core Web XP does not prescribe the contract file name or format. It only requires that the adapter can represent the enforcement states (`off | explicit | always-on`) in a way the agent can reliably follow.

### How adapters reference core files

All adapters point at the same core files. They do not duplicate the standard — they teach the agent how to read and apply it:
- `code-guidelines.md` — the governing rules and named patterns
- `code-philosophy.md` — explanatory context and examples
- `bin/pre-commit-check.sh` — mechanical checks (runs as bash, agent-agnostic)

### Existing adapters

**Claude** (implemented — `.claude/skills/web-xp*`):
Seven native skills covering all capabilities above. Project contract: `CLAUDE.md`, built from shared `AGENT.md` + Claude overlay. Skills are authored in `.claude/skills/` — the platform-native discovery path for Claude Code.

**Codex** (implemented — `adapters/codex/`):
Capability spec files and convention-based contract (`CODEX.md`). Built from shared `AGENT.md` + Codex overlay.

### Building a new adapter

To add Web XP support for another agent platform:

1. Implement the four runtime capabilities and three setup capabilities above, in whatever skill/plugin format your platform uses.
2. Point all file references at the core files (`code-guidelines.md`, `code-philosophy.md`, `bin/pre-commit-check.sh`).
3. Define a project contract mechanism that can express `off | explicit | always-on`.
4. Place adapter documentation and packaging in `adapters/<platform>/`. If the platform requires a specific path for skill discovery (e.g. `.claude/skills/` for Claude Code), authored files may live there instead — document the path in the adapter README.

The adapter does not need to implement orchestration. That is a separate layer.

### Orchestration layer (planned — not yet implemented)

smux integration is planned but not built. When implemented, it would provide:

- Role assignment: which pane is coder, which is auditor
- Message routing: findings from auditor → coder via `tmux-bridge message`
- Topology selection: single-agent, split, or continuous loop
- Agent discovery: `tmux-bridge list` to find and label panes

Depends on at least one agent adapter being installed. Does not modify core Web XP files. Orchestration remains a separate future design effort, not part of current Web XP core.

---

## Repo Structure

Core Web XP lives at the repo root. Adapter documentation and packaging live under `adapters/<platform>/`. Some adapters may also keep authored files in a platform-native path when the platform expects it (e.g. Claude skills in `.claude/skills/`).

```
web-xp/
├── AGENT.md                    # shared build source (version pin, session/commit directives)
├── code-guidelines.md          # core standard
├── code-philosophy.md          # core explanatory context
├── bin/
│   ├── pre-commit-check.sh     # core mechanical checks
│   ├── build-contracts.sh      # builds agent contracts from AGENT.md + overlays
│   └── check-web-xp-sync.sh    # internal sync (this repo only)
├── .claude/
│   └── skills/                 # Claude adapter skills (platform-native path)
│       ├── web-xp/
│       ├── web-xp-check/
│       ├── web-xp-apply/
│       ├── web-xp-review/
│       ├── web-xp-init/
│       ├── web-xp-on/
│       └── web-xp-off/
├── adapters/
│   ├── claude/                 # Claude overlay, built contract, docs
│   └── codex/                  # Codex overlay, built contract, spec files, docs
├── contrib/                    # contributor tooling (not user-facing)
│   └── AGENT-HANDOFF.md        # handoff protocol
├── test/
│   └── test-pre-commit.sh      # regression tests for pre-commit checks
├── CLAUDE.md                   # this repo's own contract
├── DESIGN.md                   # this file
└── README.md                   # public docs
```

---

## Build Order

1. ~~**Formalize enforcement modes**~~ — done.
2. ~~**Add adapter scaffolding**~~ — done.
3. ~~**Build second adapter (Codex)**~~ — done. Tested against elitefuellabs.com.
4. ~~**Rewrite public docs**~~ — done. README is agent-neutral.
5. **Design orchestration as a separate layer** — outside current Web XP core scope.
6. **Continuous audit mode** — timer-driven auditor topology using orchestration or equivalent tooling.

Steps 1-4 complete. Later orchestration work is separate from the current install/contract model.
