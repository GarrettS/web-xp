---
name: web-xp-remove
description: 'Activate when the user asks to remove Web XP from the project, clean up the project contract, uninstall from the current project, or explicitly invokes `web-xp-remove`.'
---

# Web XP Remove — Project Cleanup

<!-- DO NOT EDIT — built from /adapters/shared-base/skills/web-xp-remove.md + Claude bindings. -->

## Claude bindings

- Project contract file: `CLAUDE.md`.
- Delegate to `~/.web-xp/bin/web-xp-remove claude`.

## Shared capability

## Purpose

Remove Web XP from the current project for the concrete adapter.

## Activation

Activate when the user asks to remove Web XP from the project, clean up the project contract, uninstall from the current project, or explicitly invokes `web-xp-remove`.

## Procedure

### 1. Verify Web XP is installed

Check that `~/.web-xp/` exists. If it does not, report that Web XP is not installed and stop.

### 2. Delegate to the canonical cleanup script

Run the adapter's canonical cleanup script entrypoint. Do not reimplement the project contract mutation logic in this capability.

### 3. Report

Summarize what the script removed or updated.
