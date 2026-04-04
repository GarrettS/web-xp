---
name: web-xp-init
description: 'Activate when the user asks to initialize Web XP in a project, create or update the project contract, or explicitly invokes `web-xp-init`.'
---

# Web XP Init — Project Setup

<!-- DO NOT EDIT — built from /adapters/shared-base/skills/web-xp-init.md + Claude bindings. -->

## Claude bindings

- Project contract file: `CLAUDE.md`.
- Missing install message: `Install Web XP first: git clone https://github.com/GarrettS/web-xp.git ~/.web-xp && ~/.web-xp/bin/install.sh`
- Delegate to `~/.web-xp/bin/web-xp-init claude`.
- Claude does not require a preview-first flow in this build.

## Shared capability

## Purpose

Set up or update a project to use Web XP.

## Activation

Activate when the user asks to initialize Web XP in a project, create or update the project contract, or explicitly invokes `web-xp-init`.

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
