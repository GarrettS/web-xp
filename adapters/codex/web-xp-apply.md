# Web XP Apply — Interactive Guided Fixes

Walk through web-xp-check findings and apply them with human approval.

## Procedure

### 1. Get findings

If a web-xp-check was already run in this conversation, use those findings. Otherwise, run web-xp-check first.

### 2. Present one coherent change at a time

Group findings when they are the same kind of edit in the same file. Keep distinct structural refactors separate.

For each proposed change: file, line number(s), pattern name, violation or opportunity, current code, proposed replacement, one-sentence rationale.

Ask: "Apply this change? (yes / no / skip)"

### 3. Apply on approval

- **yes**: make the edit, verify correctness.
- **no** or **skip**: move to the next finding.
- Never edit without explicit approval.

### 4. After all findings

Report: how many applied, skipped, declined.

If any edits were made:
- Remove CSS selectors, IDs, classes, and variables made unreferenced by the refactor.
- Run `bash ~/.web-xp/bin/pre-commit-check.sh` to verify no new mechanical violations.
- Review changed JS for correctness — no broken references, missing arguments, or changed behavior.
