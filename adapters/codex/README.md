# Codex Adapter

Web XP adapter for Codex. Implements the adapter interface as discovered skill folders plus a built contract.

## Status

Implemented. Codex skill folders are built artifacts, not the canonical authored skill source.

## How it works

1. `adapters/shared-base/AGENT.md` is the shared base contract — version pin, session directives, pre-commit sequence.
2. `overlay.md` (in this adapter) adds Codex-specific contract guidance.
3. The install builds `CODEX.md` from `adapters/shared-base/AGENT.md` + `overlay.md`. Projects get one file.
4. `tools/build-adapter-skills.sh` builds the concrete Codex skill folders in this adapter from `adapters/shared-base/skills/` + Codex bindings.
5. Install copies those skill folders into `$HOME/.agents/skills/` so Codex discovers them as user-level skills.

The skill folders under `adapters/codex/skills/` are the Codex equivalents of the Claude skill directories in `adapters/claude/`.

## Skills

| Skill | Role | Purpose |
|-----------|------|---------|
| `web-xp` | both | Load constraints |
| `web-xp-check` | auditor | Audit diff |
| `web-xp-review` | auditor | Review any code |
| `web-xp-apply` | coder | Apply fixes with approval |
| `web-xp-init` | setup | Bootstrap project |
| `web-xp-on` | setup | Enable always-on enforcement |
| `web-xp-off` | setup | Disable enforcement |
| `web-xp-remove` | setup | Remove Web XP from project |

## Install

Web XP is installed once per user, not per project.

```bash
git clone https://github.com/GarrettS/web-xp.git ~/.web-xp
```

Install copies the full Codex skill set into `$HOME/.agents/skills/`.

Then in each project, inside Codex:

```text
web-xp-init
```

Shell fallback:

```bash
~/.web-xp/bin/web-xp-init codex
```

To remove Web XP from the current project inside Codex:

```text
web-xp-remove
```

Shell fallback:

```bash
~/.web-xp/bin/web-xp-remove codex
```

To update:

```bash
cd ~/.web-xp && git pull
```

### Usage

Point Codex to `CODEX.md` when starting a session. Invoke Web XP by skill name, for example:

```text
web-xp-check
```
