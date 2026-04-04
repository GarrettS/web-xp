---
name: web-xp-review
description: 'Activate when explicitly invoked by name. Auto-activate only if a Web XP project contract (`CODEX.md` or `CLAUDE.md`) exists in the project.'
---

# Web XP Review — Evaluate Any Code Against the Standards

<!-- DO NOT EDIT — built from /adapters/shared-base/skills/web-xp-review.md + Claude bindings. -->

## Claude bindings

- Read `${CLAUDE_SKILL_DIR}/../code-guidelines.md`.
- Read `${CLAUDE_SKILL_DIR}/../code-philosophy.md`.
- Use Claude slash-command names when referencing related capabilities.

## Shared capability

## Purpose

Review code the user provides against the Web XP standards. Unlike `web-xp-check`, this works on any code from any source.

## Activation

Activate when explicitly invoked by name. Auto-activate only if a Web XP project contract (`CODEX.md` or `CLAUDE.md`) exists in the project.

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

### 5. Offer next steps

Suggest specific follow-up actions based on the actual findings. If the review found nothing, say so and skip this step.
