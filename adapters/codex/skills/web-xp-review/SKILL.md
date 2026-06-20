---
name: web-xp-review
description: 'Activate when explicitly invoked by name. Auto-activate only if a Web XP project contract (`AGENTS.md`, `CLAUDE.md`, or `CODEX.md`) exists in the project.'
---

# Web XP Review — Evaluate Code and Apply Approved Fixes

<!-- DO NOT EDIT — built from /adapters/shared-base/skills/web-xp-review.md + Codex bindings. -->

## Codex bindings

- Read `~/.web-xp/code-guidelines.md`.
- Read `~/.web-xp/code-philosophy.md`.
- Make edits using Codex's normal file editing tools after explicit approval.
- Run `bash ~/.web-xp/bin/pre-commit-check.sh` after approved edits.
- Refer to related Codex capabilities without slash prefixes.

## Shared capability

## Purpose

Review code the user provides against the Web XP standards. Unlike `web-xp-check`, this works on any code from any source. Review is the default posture. If the human explicitly asks for changes or approves proposed edits, this capability can also apply fixes.

## Activation

Activate when explicitly invoked by name. Auto-activate only if a Web XP project contract (`AGENTS.md`, `CLAUDE.md`, or `CODEX.md`) exists in the project.

## Procedure

### 1. Load the standards

Read `code-guidelines.md`. For explanatory context, read `code-philosophy.md`.

### 2. Receive code to review

Accept code as:

- pasted text
- a file path
- a directory
- a URL if the adapter can inspect it
- a description of a pattern to evaluate

If nothing reviewable was provided and no obvious project target is present, ask what to review.

If framework code is provided, evaluate both the original and what the Web XP-aligned vanilla equivalent would look like.

### 3. Analyze against Web XP patterns

Assess the code against the same pattern list as `web-xp-check`:

- Event Delegation
- Active Object
- Shared Key
- Ancestor Class
- Dispatch Table
- Fail-Safe
- CSS over JS
- `hidden` attribute
- Extract Shared Logic
- Template and cloneNode

Also assess against language rules such as naming conventions, module cohesion, identifier accuracy, guard clauses, DOM content, and string concatenation.

### 4. Report findings

For each finding, report:

- pattern name
- whether it is a violation or an opportunity
- the Web XP-aligned alternative

For framework code, show the vanilla equivalent side by side.

### 5. Prompt to apply fixes

Do not auto-apply fixes. After presenting findings, ask the user: "Want me to apply these fixes?"

If the user agrees, apply fixes using this flow:

1. present one coherent change at a time by default
2. group changes only when they are the same kind of edit in the same file or tightly related scope
3. for each proposed change set, present:
   - file and line number(s)
   - pattern name and whether it is a violation or opportunity
   - current code
   - proposed replacement
   - one-sentence Web XP rationale
4. ask for approval before each change set unless the human already gave clear blanket approval to proceed
5. after approval:
   - make the edit
   - verify it was applied correctly

After all approved edits:

- report how many findings were applied, skipped, and declined
- remove selectors, IDs, classes, and variables made unreferenced by the refactor
- run the adapter's Web XP pre-commit check command
- review changed JS for correctness: no broken references, missing arguments, or changed behavior

### 6. Offer next steps

Suggest specific follow-up actions based on the actual findings. If the review found nothing, say so and skip this step.
