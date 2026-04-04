---
name: web-xp-remove
description: 'Remove Web XP from the current Codex project by deleting the managed block from CODEX.md or removing the file if it only contains Web XP. Trigger when the user says "web-xp-remove", asks to remove Web XP from a project, uninstall Web XP from the local project, or clean up CODEX.md.'
---

# Web XP Remove — Project Cleanup

<!-- DO NOT EDIT — built from /adapters/shared-base/skills/web-xp-remove.md + Codex bindings. -->

## Codex bindings

- Project contract file: `CODEX.md`.
- Delegate to `~/.web-xp/bin/web-xp-remove codex`.

## Shared capability

## Purpose

Remove Web XP from the current project for the concrete adapter.

## Procedure

### 1. Verify Web XP is installed

Check that `~/.web-xp/` exists. If it does not, report that Web XP is not installed and stop.

### 2. Delegate to the canonical cleanup script

Run the adapter's canonical cleanup script entrypoint. Do not reimplement the project contract mutation logic in this capability.

### 3. Report

Summarize what the script removed or updated.
