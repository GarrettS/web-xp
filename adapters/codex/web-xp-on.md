# Web XP On — Enable Enforcement

Activate Web XP directives in the project's `CODEX.md` so they are active for all sessions.

## Procedure

### 1. Locate CODEX.md

Look for `CODEX.md` in the project root. If it does not exist: "Run web-xp-init first." Stop.

### 2. Check for Web XP directives

Look for the "On every session" and "Before every commit" sections that reference Web XP files or checks.

If no directives exist (neither active nor commented out): "Run web-xp-init first." Stop.

### 3. Check current state

If directives are already active (not inside HTML comments): "Already on." Stop.

### 4. Uncomment

Remove HTML comment markers (`<!-- ... -->`) to activate the directives.

### 5. Report

"Web XP enforcement enabled."
