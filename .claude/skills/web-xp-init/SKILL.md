---
name: web-xp-init
description: "Set up a project with Web XP standards. Trigger: 'set up project', 'initialize', 'create CLAUDE.md', 'add pre-commit', 'init web-xp'."
---
<!-- DO NOT EDIT — canonical source is /adapters/claude/web-xp-init/SKILL.md.     This copy is auto-synced by the pre-commit hook. Edits here will be overwritten. -->
# Web XP Init — Project Setup

Set up a project to use the Web XP standards skill.

## Procedure

### 1. Verify Web XP is installed

Check that `~/.web-xp/` exists. If it does not exist, report: "Install Web XP first: `git clone https://github.com/GarrettS/web-xp.git ~/.web-xp`" and stop.

### 2. Create workflow contract

If no `CLAUDE.md` exists, copy the built contract:

```bash
cp ~/.web-xp/adapters/claude/CLAUDE.example.md CLAUDE.md
```

If `CLAUDE.md` already exists, report: "CLAUDE.md already exists — skipping."

### 3. Report

Summarize what was created or skipped.
