# Claude Adapter

Web XP adapter for Claude Code.

## Status

Implemented. This is the reference adapter.

## Where the skills live

Claude skills are authored in `.claude/skills/` at the repo root — the platform-native discovery path for Claude Code. They are not duplicated here.

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

`CLAUDE.md` — Claude Code reads this file at session start. The adapter expresses enforcement states through directives in this file:

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

To update:

```bash
cd ~/.web-xp && git pull
cp -r ~/.web-xp/.claude/skills/* ~/.claude/skills/
```

Then run `/web-xp-init` in your project to create a `CLAUDE.md` contract.
