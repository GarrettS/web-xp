---
name: doctrine-off
description: "Disable doctrine enforcement in CLAUDE.md. Activate when: 'turn off doctrine', 'disable standards', 'pause enforcement', 'doctrine off', 'skip doctrine'."
---

# Doctrine Off — Disable Enforcement

Comment out doctrine directives in the project's CLAUDE.md so they are inactive for all sessions.

## Procedure

### 1. Locate CLAUDE.md

Look for `CLAUDE.md` in the project root. If it does not exist, report: "No doctrine directives found." and stop.

### 2. Check for doctrine directives

Look for the doctrine directives — the "On every session" and "Before every commit" sections that reference `/doctrine`, `/doctrine-check`, or `bin/pre-commit-check.sh`.

If no doctrine directives exist, report: "No doctrine directives found." and stop.

### 3. Check current state

If the directives are already commented out (inside HTML comments), report: "Already off." and stop.

### 4. Comment out

Wrap each doctrine directive section in HTML comments (`<!-- ... -->`). Do not delete them — the user may want to re-enable later with `/doctrine-on`.

### 5. Report

Show the current state of the doctrine directives after the change: "Doctrine enforcement disabled."
