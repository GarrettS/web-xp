---
name: web-xp-on
description: "Enable Web XP enforcement in CLAUDE.md. Activate when: 'turn on web-xp', 'enable standards', 'activate enforcement', 'web-xp on', 're-enable'."
---
<!-- DO NOT EDIT — canonical source is /adapters/claude/web-xp-on/SKILL.md.     This copy is auto-synced by the pre-commit hook. Edits here will be overwritten. -->
# Web XP On — Enable Enforcement

Uncomment the Web XP directives inside the managed block in the project's CLAUDE.md so they are active for all sessions.

## Procedure

### 1. Locate CLAUDE.md

Look for `CLAUDE.md` in the project root. If it does not exist, report: "Run `/web-xp-init` first." and stop.

### 2. Check for the Web XP-managed block

Look for the Web XP-managed block:

```md
<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->
...
<!-- END WEB-XP -->
```

If no managed block exists, report: "Run `/web-xp-init` first." and stop.

### 3. Check for Web XP directives inside the block

Look inside the managed block for the Web XP directives — the "On every session" and "Before every commit" sections that reference `/web-xp`, `/web-xp-check`, or `bin/pre-commit-check.sh`.

If no Web XP directives exist inside the managed block (neither active nor commented out), report: "Run `/web-xp-init` first." and stop.

### 4. Check current state

If the directives inside the managed block are already active (not inside HTML comments), report: "Already on." and stop.

### 5. Uncomment

If the directives inside the managed block are wrapped in HTML comments (`<!-- ... -->`), remove the comment markers to activate them.

Never modify content outside the managed block.

### 6. Report

Show the current state of the Web XP directives after the change: "Web XP enforcement enabled."
