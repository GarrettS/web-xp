# Codex Adapter

Web XP adapter for Codex. Implements the adapter interface as capability spec files and a built contract.

## Status

Initial implementation. Capability specs are prompt/spec files that define each Web XP capability for Codex. If Codex gains a formal skill packaging system, these files become the source material for that packaging.

## How it works

1. `AGENT.md` (in the Web XP repo) is the shared base contract — version pin, session directives, pre-commit sequence.
2. `overlay.md` (in this adapter) adds Codex-specific config: spec directory, handoff protocol.
3. The install builds `CODEX.md` from `AGENT.md` + `overlay.md`. Projects get one file.
4. Capability spec files (one per Web XP capability) define what each operation does.

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

Point Codex to `CODEX.md` when starting a session. Invoke capabilities by spec file name (e.g. "follow `web-xp-check.md`").
