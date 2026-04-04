---
name: web-xp-check
description: 'Audit git diff against Web XP standard patterns. Activate when: about to commit, ''check my code'', ''audit'', ''pre-commit'', ''review the diff'', verifying quality.'
---

# Web XP Check — Read-Only Audit

<!-- DO NOT EDIT — built from /adapters/shared-base/skills/web-xp-check.md + Codex bindings. -->

## Codex bindings

- Run `bash ~/.web-xp/bin/pre-commit-check.sh`.
- Refer users to `web-xp-review` for arbitrary files outside git diff review.
- Use Codex capability names without slash prefixes.

## Shared capability

## Purpose

Audit the current diff against the Web XP standards. Report findings. Do not edit files.

## Procedure

### 1. Mechanical checks

Run the adapter's Web XP pre-commit check command. If it reports violations, list them and stop. Mechanical issues must be fixed before structural review.

### 2. Structural review

Read the **Patterns** and **Fail-Safe** sections of `code-guidelines.md`.

Get the diff to review: use `git diff --cached` if it has output, otherwise fall back to `git diff`. If both are empty, report: `No staged or unstaged changes to review.` Then point the user to the adapter's `web-xp-review` capability for existing files regardless of git state.

For each file in the diff, examine the changed lines and enough surrounding context against these patterns:

1. **Event Delegation** — Flag: `addEventListener` inside loops, inside functions called more than once, or attached to dynamically created elements.
2. **Active Object** — Flag: `querySelectorAll` scanning siblings to remove a class, or looping through a collection to find the active element.
3. **Shared Key** — Flag: `.find(item => item.id === ...)`, `querySelector('[data-id="..."]')`, or any linear scan for a known key.
4. **Ancestor Class** — Flag: JS loops toggling classes or `hidden` on multiple siblings to reflect a single state change.
5. **Dispatch Table** — Flag: `if`/`else if` chains or `switch` statements that route by string key to function calls.
6. **Fail-Safe** — Flag: `catch` blocks with only console output, silent `null`/`undefined` returns, fire-and-forget async without `.catch()`, `fetch` without checking `response.ok`.
7. **CSS over JS** — Flag: `mouseenter`/`mouseleave` handlers that only toggle classes.
8. **`hidden` attribute** — Flag: `style.display = 'none'` or `style.display = ''` toggling.
9. **Extract Shared Logic** — Flag: structural duplication in DOM construction, string building, or iteration.
10. **Template and cloneNode** — Flag: `createElement` / `setAttribute` / `classList.add` repeated identically inside a loop.

Distinguish:

- **Violation** — the diff breaks a Web XP pattern the code should already be following.
- **Opportunity** — the code works but would materially improve with a Web XP pattern.

Be selective. Only flag clear wins.

### 3. Report

For each finding, report:

- file and line number(s)
- pattern name
- type: Violation or Opportunity
- current code: brief description or quote of the problematic lines
- Web XP alternative: what the code should look like

Group findings by file. If there are no findings, report: `Web XP check passed.`

### 4. Offer next steps

After the report, prompt the user with actionable options based on the actual findings. Reference the specific file or pattern, not generic options. If there are no findings, skip this step.
