# Web XP On — Enable Enforcement

Activate the Web XP directives inside the managed block in the project's `CODEX.md` so they are active for all sessions.

## Procedure

### 1. Locate CODEX.md

Look for `CODEX.md` in the project root. If it does not exist: "Run web-xp-init first." Stop.

### 2. Check for the Web XP-managed block

Look for the Web XP-managed block:

```md
<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->
...
<!-- END WEB-XP -->
```

If no managed block exists: "Run web-xp-init first." Stop.

### 3. Check for Web XP directives inside the block

Look inside the managed block for the "On every session" and "Before every commit" sections that reference Web XP files or checks.

If no directives exist inside the managed block (neither active nor commented out): "Run web-xp-init first." Stop.

### 4. Check current state

If directives inside the managed block are already active (not inside HTML comments): "Already on." Stop.

### 5. Uncomment

Remove HTML comment markers (`<!-- ... -->`) to activate the directives inside the managed block.

Never modify content outside the managed block.

### 6. Report

"Web XP enforcement enabled."
