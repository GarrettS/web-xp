# Web XP Off — Disable Enforcement

Comment out the Web XP directives inside the managed block in the project's `CODEX.md` so they are inactive for all sessions.

## Procedure

### 1. Locate CODEX.md

Look for `CODEX.md` in the project root. If it does not exist: "No Web XP directives found." Stop.

### 2. Check for the Web XP-managed block

Look for the Web XP-managed block:

```md
<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->
...
<!-- END WEB-XP -->
```

If no managed block exists: "No Web XP directives found." Stop.

### 3. Check for Web XP directives inside the block

Look inside the managed block for the "On every session" and "Before every commit" sections that reference Web XP files or checks.

If no directives exist inside the managed block: "No Web XP directives found." Stop.

### 4. Check current state

If directives inside the managed block are already commented out (inside HTML comments): "Already off." Stop.

### 5. Comment out

Wrap each directive section inside the managed block in HTML comments (`<!-- ... -->`). Do not delete them — the user may want to re-enable later.

Never modify content outside the managed block.

### 6. Report

"Web XP enforcement disabled."
