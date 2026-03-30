# Web XP Off — Disable Enforcement

Comment out Web XP directives in the project's `CODEX.md` so they are inactive for all sessions.

## Procedure

### 1. Locate CODEX.md

Look for `CODEX.md` in the project root. If it does not exist: "No Web XP directives found." Stop.

### 2. Check for Web XP directives

Look for the "On every session" and "Before every commit" sections that reference Web XP files or checks.

If no directives exist: "No Web XP directives found." Stop.

### 3. Check current state

If directives are already commented out (inside HTML comments): "Already off." Stop.

### 4. Comment out

Wrap each directive section in HTML comments (`<!-- ... -->`). Do not delete them — the user may want to re-enable later.

### 5. Report

"Web XP enforcement disabled."
