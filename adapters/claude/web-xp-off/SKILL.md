---
name: web-xp-off
description: 'Activate when the user asks to turn Web XP off, disable standards, pause enforcement, or explicitly invokes `web-xp-off`.'
---

# Web XP Off — Disable Enforcement

<!-- DO NOT EDIT — built from /adapters/shared-base/skills/web-xp-off.md + Claude bindings. -->

## Claude bindings

- Project contract file: `CLAUDE.md`.
- Delegate to `~/.web-xp/bin/web-xp-off claude`.

## Shared capability

## Purpose

Remove Web XP from the current project's adapter contract.

## Activation

Activate when the user asks to turn Web XP off, disable standards, pause enforcement, or explicitly invokes `web-xp-off`.

## Procedure

### 1. Verify Web XP is installed

Check that `~/.web-xp/` exists. If it does not, report that Web XP is not installed and stop.

### 2. Delegate to the canonical cleanup script

Run the adapter's canonical cleanup script entrypoint. Do not reimplement the project contract mutation logic in this capability.

The cleanup behavior is:

- remove the Web XP-managed block from the adapter contract file
- delete the contract file if it only contained the managed block
- leave content outside the managed block untouched

### 3. Report

Report: "Web XP enforcement is disabled. Do not apply Web XP standards or run pre-commit checks unless explicitly asked."

This wording is a behavioral instruction, not just a status message. It must remain in the conversation context so the agent stops enforcing for the rest of the session.
