# Web XP Apply — Interactive Guided Fixes

Adapter-neutral source for the `web-xp-apply` capability.

## Purpose

Walk through `web-xp-check` findings and apply them with human approval.

## Activation

Activate when explicitly invoked by name. Auto-activate only if a Web XP project contract (`CODEX.md` or `CLAUDE.md`) exists in the project.

## Adapter bindings

The concrete adapter wrapper must provide:

- how to invoke or reference `web-xp-check`
- how edits are performed in that adapter
- how to run the Web XP pre-commit check

## Procedure

### 1. Get findings

If a `web-xp-check` was already run in this conversation, use those findings. Otherwise, run it first.

### 2. Present one coherent change at a time

Default to one finding at a time, but group findings when they are the same kind of edit in the same file or tightly related scope.

Examples that should be grouped into one approval:

- repeated renames in one file caused by one naming correction
- repeated class or ID renames caused by one correction
- repeated mechanical replacements of the same anti-pattern in one module

Examples that should stay separate:

- distinct structural refactors in different files
- changes affecting different Web XP patterns
- any edit where grouping would make the proposal harder to review

For each proposed change set, present:

- file and line number(s)
- pattern name and whether it is a violation or opportunity
- current code
- proposed replacement
- one-sentence Web XP rationale

Then ask: `Apply this change? (yes / no / skip)`

### 3. Apply on approval

- `yes`: make the edit and verify it was applied correctly
- `no` or `skip`: move to the next finding
- never edit without explicit approval for that specific change

### 4. After all findings

Report how many findings were applied, skipped, and declined.

If any edits were made:

- remove selectors, IDs, classes, and variables made unreferenced by the refactor
- run the adapter's Web XP pre-commit check command
- review changed JS for correctness: no broken references, missing arguments, or changed behavior
