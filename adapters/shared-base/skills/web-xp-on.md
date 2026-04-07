# Web XP On — Enable Enforcement

Adapter-neutral source for the `web-xp-on` capability.

## Purpose

Set up or update the adapter's project contract so Web XP enforcement is active for the current project.

## Activation

Activate when the user asks to turn Web XP on, enable standards, re-enable enforcement, or explicitly invokes `web-xp-on`.

## Adapter bindings

The concrete adapter wrapper must provide:

- the project contract filename
- the install command to show when Web XP is missing
- the canonical shell bootstrap command, if the adapter delegates to it
- whether the adapter requires preview before write

## Procedure

### 1. Verify Web XP is installed

Check that `~/.web-xp/` exists. If it does not, tell the user how to install Web XP and stop.

### 2. Create or update the project contract

Use this Web XP-managed block:

```md
<!-- BEGIN WEB-XP: managed block. Edit outside this block. Changes inside may be replaced by Web XP commands. -->
...
<!-- END WEB-XP -->
```

If the concrete adapter delegates to the canonical shell bootstrap script, use that script rather than reimplementing the file mutation logic.

If the contract file does not exist, create it from the adapter's built contract template.

If the contract file already exists:

- if the managed block is missing, prepend the built contract block to the file
- if the managed block exists, replace that block with the current built contract block
- if the existing block differs from the current built contract block, warn that changes inside the managed block will be replaced, then replace it

Never modify content outside the Web XP-managed block.

### 3. Report

Summarize what was created or updated, and whether the managed block was replaced.

Report: "Web XP enforcement is enabled. Apply Web XP standards to new code and run pre-commit checks before commits."

This wording is a behavioral instruction, not just a status message. It must remain in the conversation context so the agent enforces for the rest of the session.
