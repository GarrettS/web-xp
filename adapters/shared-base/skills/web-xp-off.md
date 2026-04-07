# Web XP Off — Disable Enforcement

Adapter-neutral source for the `web-xp-off` capability.

## Purpose

Remove Web XP from the current project's adapter contract.

## Activation

Activate when the user asks to turn Web XP off, disable standards, pause enforcement, or explicitly invokes `web-xp-off`.

## Adapter bindings

The concrete adapter wrapper must provide:

- the install error message to show when `~/.web-xp/` is missing
- the canonical shell cleanup command for that adapter
- the project contract filename used in the user-facing explanation

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
