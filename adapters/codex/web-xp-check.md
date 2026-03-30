# Web XP Check — Read-Only Audit

Audit the current diff against the Web XP standards. Report findings. Do not edit any files.

## Step 1 — Mechanical checks

Run `bash ~/.web-xp/bin/pre-commit-check.sh`. If it reports violations, list them and stop — mechanical issues must be fixed before structural review.

## Step 2 — Structural review

Read the Patterns and Fail-Safe sections of `code-guidelines.md` from your Web XP install.

Get the diff: use `git diff --cached` if it has output, otherwise `git diff`. If both are empty, report "No staged or unstaged changes to review. To review existing files regardless of git state, use `web-xp-review`." and stop.

For each file in the diff, examine the changed lines (and sufficient surrounding context) against these patterns:

1. **Event Delegation** — Flag: `addEventListener` inside loops, inside functions called more than once, or attached to dynamically created elements.
2. **Active Object** — Flag: `querySelectorAll` scanning siblings to remove a class, or looping to find the active element.
3. **Shared Key** — Flag: `.find(item => item.id === ...)`, `querySelector('[data-id="..."]')`, or any linear scan for a known key.
4. **Ancestor Class** — Flag: JS loops toggling classes on multiple siblings for a single state change.
5. **Dispatch Table** — Flag: `if`/`else if` chains or `switch` routing by string key.
6. **Fail-Safe** — Flag: `catch` with only console output, silent `null`/`undefined` returns, `fetch` without `response.ok`.
7. **CSS over JS** — Flag: `mouseenter`/`mouseleave` handlers that only toggle classes.
8. **`hidden` attribute** — Flag: `style.display = 'none'`/`''` toggling.
9. **Extract Shared Logic** — Flag: structural duplication in DOM construction or iteration.
10. **Template and cloneNode** — Flag: `createElement`/`setAttribute`/`classList.add` repeated identically inside a loop.

## Step 3 — Report

For each finding: file, line number(s), pattern name, violation or opportunity, current code, Web XP alternative.

Group by file. If no findings: "Web XP check passed."
