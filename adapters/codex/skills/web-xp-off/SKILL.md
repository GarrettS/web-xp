---
name: web-xp-off
description: 'Disable Web XP enforcement in CODEX.md. Activate when: ''turn off web-xp'', ''disable standards'', ''pause enforcement'', ''web-xp off'', ''skip web-xp''.'
---

# Web XP Off — Disable Enforcement

<!-- DO NOT EDIT — built from /adapters/shared-base/skills/web-xp-off.md + Codex bindings. -->

## Codex bindings

- Project contract file: `CODEX.md`.
- Recognize Web XP directives by the `On every session` and `Before every commit` sections in the managed block.

## Shared capability

## Purpose

Comment out the Web XP directives inside the managed block in the adapter's project contract so they are inactive for all sessions.

## Procedure

### 1. Locate the project contract

Look for the adapter's project contract file in the project root. If it does not exist, report that no Web XP directives were found and stop.

### 2. Check for the Web XP-managed block

Look for:

```md
<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->
...
<!-- END WEB-XP -->
```

If no managed block exists, report that no Web XP directives were found and stop.

### 3. Check for directives inside the block

Look inside the managed block for the adapter's Web XP directives.

If no directives exist inside the block, report that no Web XP directives were found and stop.

### 4. Check current state

If the directives are already commented out, report `Already off.` and stop.

### 5. Comment out

Wrap each directive section inside the managed block in HTML comments. Do not delete them.

Never modify content outside the managed block.

### 6. Report

Report that Web XP enforcement is disabled.
