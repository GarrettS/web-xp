---
name: web-xp-off
description: "Disable Web XP enforcement in CLAUDE.md. Activate when: 'turn off web-xp', 'disable standards', 'pause enforcement', 'web-xp off', 'skip web-xp'."
---
<!-- DO NOT EDIT — canonical source is /adapters/claude/web-xp-off/SKILL.md.     This copy is auto-synced by the pre-commit hook. Edits here will be overwritten. -->
# Web XP Off — Disable Enforcement

Comment out Web XP directives in the project's CLAUDE.md so they are inactive for all sessions.

## Procedure

### 1. Locate CLAUDE.md

Look for `CLAUDE.md` in the project root. If it does not exist, report: "No Web XP directives found." and stop.

### 2. Check for Web XP directives

Look for the Web XP directives — the "On every session" and "Before every commit" sections that reference `/web-xp`, `/web-xp-check`, or `bin/pre-commit-check.sh`.

If no Web XP directives exist, report: "No Web XP directives found." and stop.

### 3. Check current state

If the directives are already commented out (inside HTML comments), report: "Already off." and stop.

### 4. Comment out

Wrap each Web XP directive section in HTML comments (`<!-- ... -->`). Do not delete them — the user may want to re-enable later with `/web-xp-on`.

### 5. Report

Show the current state of the Web XP directives after the change: "Web XP enforcement disabled."
