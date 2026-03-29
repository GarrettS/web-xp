# Codex Adapter

Web XP adapter for Codex. Implements the adapter interface as capability spec files and a convention-based contract template.

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

`AGENTS.md` — a convention-based contract file. Copy `AGENTS.example.md` to `AGENTS.md` in your project root.

The contract references all Web XP files from `.web-xp/` and defines `.web-xp/adapters/codex/` as the spec directory.

## Install

```bash
git submodule add https://github.com/GarrettS/web-xp.git .web-xp
cp .web-xp/adapters/codex/AGENTS.example.md AGENTS.md
```

### Usage

Tell Codex to read `AGENTS.md` at the start of each session. When invoking a specific capability, tell Codex to follow the corresponding spec file by name (e.g. "follow `web-xp-check.md` to audit the current diff"). The contract tells Codex where to find the spec files.
