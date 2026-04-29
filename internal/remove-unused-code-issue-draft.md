# Draft Issue: Add: Remove Unused Code

## Summary

The doctrine has no rule for unused code. Line 607 covers unused
*comments*; nothing covers unused code, properties, values, objects,
files, or network requests. Add Remove Unused Code as a standalone rule,
paired with the existing dead-comments rule.

## Problem

AI-assisted development accumulates residue across every layer:

- Unreachable code, unused exports, orphan modules, unread variables.
- Unused properties, values, and objects — set once, never read.
- Files that nothing references.
- HTTP requests whose responses are not used.

Without a rule, the residue accumulates and biases future AI generation
toward more of the same. The dead-comments rule already names the right
principle for one surface; extend it to code.

## Proposed rule

> **Remove unused code.** Unreachable code, unused exports, unread
> variables, unused properties and objects, orphan files, and HTTP
> requests whose responses are not used are clutter. They mislead
> readers, bias AI generation, and accumulate faster than they get
> cleaned up. Remove unused code, including code that becomes unused as a
> result. Version control preserves history; the working tree should not.
> No `_unused` renames, no re-exports of removed names, no `// removed`
> tombstone comments.

## Acceptance criteria

- `code-guidelines.md` has a Remove Unused Code rule.
- Covers, at minimum: unreachable code, unused exports, unread
  variables, unused properties / values / objects, orphan files, and
  unused HTTP requests.
- A change removes any code it made unused, within the same change.
- States the in-flight boundary explicitly: code may be briefly unused
  within a single change when its replacement lands in the same commit;
  the rule fires at commit boundary, not at intermediate diff state.
- Always-on feature flags and unused configuration entries are in scope.
- No-tombstone position: no `_unused` renames, no re-exports of removed
  names, no `// removed` comments.
- References version control as the historical record.

## Out of scope

- Lint or pre-commit enforcement.
- Sweeping the existing repo. The rule precedes the sweep.
