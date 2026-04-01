---
name: web-xp-init
description: "Set up or update a project with Web XP standards. Trigger: 'set up project', 'initialize', 'create CLAUDE.md', 'update CLAUDE.md', 'add pre-commit', 'init web-xp'."
---
<!-- DO NOT EDIT — canonical source is /adapters/claude/web-xp-init/SKILL.md.     This copy is auto-synced by the pre-commit hook. Edits here will be overwritten. -->
# Web XP Init — Project Setup

Set up or update a project to use the Web XP standards skill.

## Procedure

### 1. Verify Web XP is installed

Check that `~/.web-xp/` exists. If it does not exist, report: "Install Web XP first: `git clone https://github.com/GarrettS/web-xp.git ~/.web-xp`" and stop.

### 2. Create or update workflow contract

Use this Web XP-managed block:

```md
<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->
...
<!-- END WEB-XP -->
```

If no `CLAUDE.md` exists, copy the built contract:

```bash
cp ~/.web-xp/adapters/claude/CLAUDE.example.md CLAUDE.md
```

If `CLAUDE.md` already exists:

- if the Web XP-managed block is missing, append the built contract block to the end of the file
- if the Web XP-managed block already exists, replace that block with the current built contract block
- if the existing block differs from the current built contract block, warn that changes inside the managed block will be replaced, then replace it

Never modify content outside the Web XP-managed block.

### 3. Report

Summarize what was created or updated, and whether the managed block was replaced.
