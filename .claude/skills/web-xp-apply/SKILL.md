---
name: web-xp-apply
description: "Fix Web XP violations interactively with approval. Activate when: 'fix these', 'apply suggestions', 'refactor against standards', 'walk me through fixes'."
---
<!-- DO NOT EDIT — canonical source is /adapters/claude/web-xp-apply/SKILL.md.     This copy is auto-synced by the pre-commit hook. Edits here will be overwritten. -->
# Web XP Apply — Interactive Guided Fixes

Walk through web-xp-check findings and apply them with human approval, grouping repeated similar edits when they form one coherent change.

## Procedure

### 1. Get findings

If a web-xp-check was already run in this conversation, use those findings. Otherwise, run `/web-xp-check` first to generate the finding list.

### 2. Present one coherent change at a time

Default to one finding at a time, but group findings when they are the same kind of edit in the same file or tightly related scope.

Examples that should be grouped into one approval:
- Repeated camelCase-to-kebab-case or prefix renames in one file
- Repeated class/ID renames caused by one naming correction
- Repeated mechanical replacements of the same anti-pattern in one module

Examples that should stay separate:
- Distinct structural refactors in different files
- Changes that affect different Web XP patterns
- Any edit where grouping would make the proposal harder to review

For each proposed change set, present:
- The file and line number(s)
- The pattern name and whether it is a violation or opportunity
- The current code (quote the relevant lines)
- The proposed change (show the replacement code)
- A one-sentence Web XP rationale

Then ask: "Apply this change? (yes / no / skip)"

### 3. Apply on approval

- On **yes**: make the edit using the Edit tool. Verify the edit was applied correctly.
- On **no** or **skip**: move to the next finding without editing.
- Group repeated similar edits into one approval when they form a coherent review unit.
- Do not batch unrelated or structurally distinct edits together.
- Never edit without explicit approval for that specific change.

### 4. After all findings

Report a summary: how many findings were applied, skipped, and declined.

If any edits were made:
- Clean up after each edit: remove CSS selectors, IDs, classes, and variables that the refactor made unreferenced.
- Run the pre-commit script (`bin/pre-commit-check.sh` if it exists in the project, otherwise `bash ${CLAUDE_SKILL_DIR}/../pre-commit-check.sh`) to verify no mechanical violations were introduced.
- Review the changed JS for correctness — confirm no broken references, missing arguments, or changed behavior.
