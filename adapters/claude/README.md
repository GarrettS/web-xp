# Claude Adapter

Web XP adapter for Claude Code.

## Status

Implemented. This is the reference adapter.

## How it works

1. `AGENT.md` (in the Web XP repo) is the shared base contract — version pin, session directives, pre-commit sequence.
2. `overlay.md` (in this adapter) adds Claude-specific config: slash commands.
3. `tools/build-contracts.sh` builds `CLAUDE.example.md` from `AGENT.md` + `overlay.md`. Projects copy the built output.
4. Claude skill source in this adapter is synced into `.claude/skills/` for local development and install packaging.

## Where the skills live

Claude skill source is authored in `adapters/claude/`. The repo-local `.claude/skills/` tree is generated/local packaging output for Claude Code's platform-native discovery path.

| Skill | Role | Purpose |
|-------|------|---------|
| `web-xp` | both | Load constraints |
| `web-xp-check` | auditor | Audit diff |
| `web-xp-review` | auditor | Review any code |
| `web-xp-apply` | coder | Apply fixes with approval |
| `web-xp-init` | setup | Bootstrap project |
| `web-xp-on` | setup | Enable always-on enforcement |
| `web-xp-off` | setup | Disable enforcement |

## Project contract

`CLAUDE.md` — built from `AGENT.md` + Claude overlay. Claude Code reads this file at session start.

| State | Representation |
|-------|---------------|
| off | Directives commented out (`<!-- ... -->`) |
| explicit | No directives present |
| always-on | Active directives |

## Install

Web XP is installed once per user, not per project.

```bash
git clone https://github.com/GarrettS/web-xp.git ~/.web-xp
mkdir -p ~/.claude/skills
cp -r ~/.web-xp/.claude/skills/* ~/.claude/skills/
```

Then in each project:

```bash
cp ~/.web-xp/adapters/claude/CLAUDE.example.md CLAUDE.md
```

Or run `/web-xp-init` to do it automatically.

To update:

```bash
cd ~/.web-xp && git pull
cp -r ~/.web-xp/.claude/skills/* ~/.claude/skills/
```
