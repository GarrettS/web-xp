# Codex Adapter

Web XP adapter for Codex. Implements the adapter interface as capability spec files and a convention-based contract template.

## Status

Initial implementation. Capability specs are prompt/spec files that define each Web XP capability for Codex. If Codex gains a formal skill packaging system, these files become the source material for that packaging.

## How it works

Codex does not have a built-in project contract mechanism like Claude's `CLAUDE.md`. This adapter defines one by convention:

1. A project contract file (`CODEX.md`) tells Codex what to read and run each session.
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

`CODEX.md` — a convention-based contract file. Copy `CODEX.example.md` to `CODEX.md` in your project root.

The contract references Web XP files from the external install (`~/.web-xp/`) and defines `~/.web-xp/adapters/codex/` as the spec directory.

## Install

Web XP is installed once per user, not per project.

```bash
git clone https://github.com/GarrettS/web-xp.git ~/.web-xp
```

Then in each project:

```bash
cp ~/.web-xp/adapters/codex/CODEX.example.md CODEX.md
```

To update:

```bash
cd ~/.web-xp && git pull
```

### Usage

Point Codex to `CODEX.md` when starting a session. When invoking a specific capability, tell Codex to follow the corresponding spec file by name (e.g. "follow `web-xp-check.md`"). The contract tells Codex where to find the spec files.
