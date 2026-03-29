---
name: doctrine-on
description: "Enable doctrine enforcement in CLAUDE.md. Activate when: 'turn on doctrine', 'enable standards', 'activate enforcement', 'doctrine on', 're-enable'."
---

# Doctrine On — Enable Enforcement

Uncomment doctrine directives in the project's CLAUDE.md so they are active for all sessions.

## Procedure

### 1. Locate CLAUDE.md

Look for `CLAUDE.md` in the project root. If it does not exist, report: "Run `/doctrine-init` first." and stop.

### 2. Check for doctrine directives

Look for the doctrine directives — the "On every session" and "Before every commit" sections that reference `/doctrine`, `/doctrine-check`, or `bin/pre-commit-check.sh`.

If no doctrine directives exist (neither active nor commented out), report: "Run `/doctrine-init` first." and stop.

### 3. Check current state

If the directives are already active (not inside HTML comments), report: "Already on." and stop.

### 4. Uncomment

If the directives are wrapped in HTML comments (`<!-- ... -->`), remove the comment markers to activate them.

### 5. Report

Show the current state of the doctrine directives after the change: "Doctrine enforcement enabled."
