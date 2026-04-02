---
name: web-xp-remove
description: "Remove Web XP from this Claude project by deleting the managed block from CLAUDE.md or removing the file if it only contains Web XP. Trigger: 'remove web-xp', 'uninstall from project', 'clean up CLAUDE.md', 'web-xp remove'."
---
<!-- DO NOT EDIT — canonical source is /adapters/claude/web-xp-remove/SKILL.md.     This copy is auto-synced by the pre-commit hook. Edits here will be overwritten. -->
# Web XP Remove — Project Cleanup

Remove Web XP from the current project for Claude.

## Procedure

### 1. Verify Web XP is installed

Check that `~/.web-xp/` exists. If it does not exist, report: "Web XP is not installed at `~/.web-xp`." and stop.

### 2. Delegate to the canonical cleanup script

Run:

```bash
~/.web-xp/bin/web-xp-remove claude
```

That script is the canonical implementation for removing the Web XP-managed block from the project-local `CLAUDE.md` contract, or removing the file entirely if it only contains Web XP.

### 3. Report

Summarize what the script removed or updated.
