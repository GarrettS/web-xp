# Web XP Remove — Project Cleanup

Adapter-neutral source for the `web-xp-remove` capability.

## Purpose

Remove Web XP from the current project for the concrete adapter.

## Activation

Activate when the user asks to remove Web XP from the project, clean up the project contract, uninstall from the current project, or explicitly invokes `web-xp-remove`.

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

### 3. Report

Summarize what the script removed or updated.
