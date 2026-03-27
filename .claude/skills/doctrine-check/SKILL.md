---
name: doctrine-check
description: "Read-only audit of the current git diff against all 10 code standard patterns. Reports violations and opportunities without editing files."
---

# Doctrine Check — Read-Only Audit

Audit the current diff against the code standards. Report findings. Do not edit any files.

## Step 1 — Mechanical checks

Run the pre-commit script via `bash ${CLAUDE_SKILL_DIR}/../pre-commit-check.sh` if no project-local `bin/pre-commit-check.sh` exists. If it reports violations, list them and stop — mechanical issues must be fixed before structural review.

## Step 2 — Structural review

Read the **Patterns** and **Fail-Safe** sections of `${CLAUDE_SKILL_DIR}/../code-guidelines.md`.

Get the diff to review: use `git diff --cached` if it has output, otherwise fall back to `git diff`. If both are empty, report "No staged or unstaged changes to review" and stop.

For each file in the diff, examine the changed lines (and sufficient surrounding context) against the patterns defined below. Look for two categories:

### Violations — code that breaks a pattern already in use

A violation means the diff introduces code that contradicts a pattern the codebase already follows. Examples:
- Adding `querySelectorAll` to clear active state when the module already tracks an active reference (breaks **Active Object**)
- Adding per-element `addEventListener` in a build/render function (breaks **Event Delegation**)
- Using `.find()` or `querySelector('[data-id=...]')` to look up an entity by known key (breaks **Shared Key**)
- A `catch` block that logs to console without user-visible feedback (breaks **Fail-Safe**)
- JS toggling classes on multiple siblings instead of one class on an ancestor (breaks **Ancestor Class**)

### Opportunities — code that would benefit from a pattern not yet applied

An opportunity means the diff contains code that works but would be cleaner, faster, or more maintainable with a doctrine pattern. Be selective — only flag clear wins, not marginal cases.

**Pattern definitions for recognition:**

1. **Event Delegation** — Attach one listener to a stable ancestor, inspect `event.target`. Flag: `addEventListener` inside loops, inside functions called more than once, or attached to dynamically created elements.

2. **Active Object** — Hold a reference to the currently active element. On switch, deactivate it directly, activate the new one. Flag: `querySelectorAll` scanning siblings to remove a class, or looping through a collection to find the active element.

3. **Shared Key** — One ID string indexes data (object property), DOM (`getElementById`), and dispatch (action route). Flag: `.find(item => item.id === ...)`, `querySelector('[data-id="..."]')`, or any linear scan for a known key. Also flag: array-of-objects JSON when the data is looked up by key (should be a keyed object).

4. **Ancestor Class** — Style a group of descendants by adding one class to their common ancestor; CSS cascade handles the rest. Flag: JS loops toggling classes or `hidden` on multiple siblings to reflect a single state change.

5. **Dispatch Table** — Replace conditional chains mapping values to actions with a keyed object. Flag: `if`/`else if` chains or `switch` statements that route by string key to function calls.

6. **Fail-Safe** — Every failure resolves to a user-visible outcome. Flag: `catch` blocks with only `console.error`/`console.log`, functions that return `null`/`undefined` on failure without caller notification, `async` calls without `await` and without `.catch()`, `fetch` without checking `response.ok`.

7. **CSS over JS** — Use CSS for visual state changes (`:hover`, `:focus`, `:not()`, `pointer-events`) instead of JS event handlers. Flag: `mouseenter`/`mouseleave` handlers that only toggle classes, JS `disabled` toggling when CSS `pointer-events: none` suffices.

8. **`hidden` attribute** — Use `el.hidden` for show/hide instead of `style.display`. Flag: `style.display = 'none'` / `style.display = ''` toggling.

9. **Extract Shared Logic** — When two or more blocks follow the same structure with different values, extract a parameterized function. Flag: structural duplication in DOM construction, string building, or iteration.

10. **Template and cloneNode** — When creating multiple similar elements in a loop, build one template element outside the loop with shared attributes and classes, then `cloneNode()` inside the loop and set only per-instance values. Use `cloneNode(false)` for leaf elements, `cloneNode(true)` when the template has children. Flag: `createElement` / `setAttribute` / `classList.add` repeated identically inside a loop.

## Step 3 — Report

For each finding, report:
- **File** and **line number(s)**
- **Pattern name**
- **Type**: Violation or Opportunity
- **Current code**: brief description or quote of the problematic lines
- **Doctrine-aligned alternative**: what the code should look like

Group findings by file. If no findings: report "Doctrine check passed."

### 4. Offer next steps

After the report, prompt the user with actionable options based on what was found. Examples:

- "Want me to walk through these one at a time and apply fixes? (`/doctrine-apply`)"
- "Want me to fix the [specific pattern] violations first?"
- "Want me to show the doctrine-aligned alternative for the [specific file] findings?"

Tailor the prompts to the specific findings. Do not offer generic options — reference the actual violations and opportunities from the report. If no findings, skip this step.
