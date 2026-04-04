# Web XP On — Enable Enforcement

Adapter-neutral source for the `web-xp-on` capability.

## Purpose

Activate the Web XP directives inside the managed block in the adapter's project contract so they are active for all sessions.

## Activation

Activate when the user asks to turn Web XP on, enable standards, re-enable enforcement, or explicitly invokes `web-xp-on`.

## Adapter bindings

The concrete adapter wrapper must provide:

- the project contract filename
- any adapter-native command spelling shown to the user
- the adapter-specific identifiers used to recognize Web XP directives

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
