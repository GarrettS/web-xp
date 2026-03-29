# Codex Adapter

Web XP adapter for Codex. Implements the adapter interface as capability spec files and contract templates.

## Status

Initial implementation. Capability specs are prompt/spec files that define each Web XP capability for Codex. If Codex gains a formal skill packaging system, these files become the source material for that packaging.

## How it works

Codex does not have a built-in project contract mechanism like Claude's `CLAUDE.md`. This adapter defines one by convention:

1. A project contract file (`AGENTS.md`) tells Codex what to read and run each session.
2. Capability spec files (one per Web XP capability) define what each operation does.
3. The user tells Codex to follow the contract and use the spec files.

## Capabilities

| Spec file | Role | Purpose |
|-----------|------|---------|
| `web-xp.md` | both | Load constraints |
| `web-xp-check.md` | auditor | Audit diff |
| `web-xp-review.md` | auditor | Review any code |
| `web-xp-apply.md` | coder | Apply fixes with approval |
| `web-xp-init.md` | setup | Bootstrap project |
| `web-xp-on.md` | setup | Enable always-on enforcement |
| `web-xp-off.md` | setup | Disable enforcement |

## Project contract

`AGENTS.md` — a convention-based contract file. Two example templates are provided:

- `AGENTS.submodule.example.md` — for projects that vendor Web XP as a git submodule at `.web-xp/`
- `AGENTS.skill.example.md` — for projects where spec files are installed locally

Copy the appropriate example to `AGENTS.md` in your project root.

## Install

### Submodule consumer

```bash
git submodule add https://github.com/GarrettS/web-xp.git .web-xp
cp .web-xp/adapters/codex/AGENTS.submodule.example.md AGENTS.md
```

### Spec file consumer

```bash
git clone https://github.com/GarrettS/web-xp.git ~/.web-xp
cp ~/.web-xp/code-guidelines.md code-guidelines.md
cp ~/.web-xp/code-philosophy.md code-philosophy.md
mkdir -p bin
cp ~/.web-xp/bin/pre-commit-check.sh bin/pre-commit-check.sh
cp ~/.web-xp/adapters/codex/web-xp*.md .
cp ~/.web-xp/adapters/codex/AGENTS.skill.example.md AGENTS.md
```

### Usage

Tell Codex to read `AGENTS.md` at the start of each session. When invoking a specific capability, tell Codex to follow the corresponding spec file (e.g. "follow `web-xp-check.md` to audit the current diff").
