---
name: web-xp-on
description: 'Enable Web XP enforcement in CLAUDE.md. Activate when: ''turn on web-xp'', ''enable standards'', ''activate enforcement'', ''web-xp on'', ''re-enable''.'
---

# Web XP On — Enable Enforcement

<!-- DO NOT EDIT — built from /adapters/shared-base/skills/web-xp-on.md + Claude bindings. -->

## Claude bindings

- Project contract file: `CLAUDE.md`.
- Tell the user to run `/web-xp-init` if setup is missing.
- Recognize Web XP directives by the `On every session` and `Before every commit` sections in the managed block.

## Shared capability

## Purpose

Activate the Web XP directives inside the managed block in the adapter's project contract so they are active for all sessions.

## Procedure

### 1. Locate the project contract

Look for the adapter's project contract file in the project root. If it does not exist, tell the user to run the adapter's `web-xp-init` capability first and stop.

### 2. Check for the Web XP-managed block

Look for:

```md
<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->
...
<!-- END WEB-XP -->
```

If no managed block exists, tell the user to run the adapter's `web-xp-init` capability first and stop.

### 3. Check for directives inside the block

Look inside the managed block for the adapter's Web XP directives.

If no directives exist inside the block, neither active nor commented out, tell the user to run `web-xp-init` first and stop.

### 4. Check current state

If the directives are already active, report `Already on.` and stop.

### 5. Uncomment

Remove HTML comment markers around the directive sections to activate them.

Never modify content outside the managed block.

### 6. Report

Report that Web XP enforcement is enabled.
