# Strategy: Route out meta-mode in issues

Reusable prompt for cleaning meta-mode leakage out of existing issue text. Apply per-issue with explicit authorization. Used as pre-triage cleanup pass.

## Authority

`editorial-rules.md` is the canonical source for meta-mode-leakage patterns. The pattern list below is a working copy of that section. Source-of-truth conflicts resolve by `editorial-rules.md`.

Build-script composition deferred — duplication is acceptable for one extraction.

## Inputs

- Target: issue number N (or list of numbers).
- Optional: scope (body only, or body + comments).

## Procedure

1. Read the issue body and (if in scope) comments.
2. Detect meta-mode patterns (list below).
3. Classify each match: **Confirmed leakage** / **Legitimate use** / **Ambiguous**. Default to Ambiguous when uncertain.
4. Produce a fix list: anchor (line or paragraph) + proposed change + one-line rationale.
5. Do not edit the issue without per-action authorization. Each issue is authorized separately.

## Patterns to detect

- **Self-references** — *"this issue"*, *"the issue scope"*, *"this issue ships"*. Legitimate use: dependency notes (*"this depends on #56"*) and explicit scope statements.
- **Scope defenses** — *"not narrowed to X"*, *"not just Y"*, *"the broader Z"*. Often defensive positioning against drafting feedback.
- **Revision narration** — *"the point of the pilot is"*, *"what this demonstrates"*. Often explains what the artifact does instead of doing it.
- **Instructional leaks** — drafting instructions to the producing agent transcribed as artifact content.
- **Meta-ACs** — acceptance criteria about what's in the artifact body rather than what gets delivered.
- **Surface-vs-target conflations** — listing the file where a rule lives (delivery surface) as if it were an artifact class the rule reviews (review target).

## Output format

Per issue:

```
### Issue #N — fix list

[Anchor: line or paragraph]
- Pattern: [pattern name]
- Match: [quoted text]
- Class: Confirmed leakage / Legitimate use / Ambiguous
- Proposed change: [rewrite or deletion]
- Rationale: [one line]
```

## Anti-fixation

This strategy is narrowly about meta-mode in issue text. Do not extend to:

- Tone, style, conciseness — those are separate editorial concerns.
- Triage actions (assign, close, label) — orthogonal.
- Doctrine review — different scope.
- Hunting meta-mode as a concern *inside* other artifacts the issue references.

One pass, one concern.

## Constraints

- No bulk edits. Per-issue authorization only.
- No silent rewrites. Output a fix list; human or human-authorized agent applies.
- Default to Ambiguous. Reviewer judgment over agent confidence.
