# Notes: Web XP #40 Shared Key Doctrine

Working notes for Web XP issue #40. These are not the Shared Key Pattern entry.
The entry draft lives in `internal/shared-key-entry-draft.md`.

## Drafting Approach

Do not define Shared Key structure in the abstract. Use representative Pelvis
examples to discover and pressure-test the entry before finalizing it.

This is the dependency correction from #33: structure cannot be finished before
we know the kinds of doctrine the structure must hold. For Shared Key, that
means looking at real code before deciding the final shape of the Pattern
entry. The entry needs enough evidence to distinguish key slots, code smells,
legitimate iteration, related patterns, and non-changes.

The goal is not to mine every possible Shared Key example or complete the
Pelvis refactors first. The goal is to learn enough from real code to write the
compact pattern entry and its review shape without making Shared Key carry every
related pattern.

## How Deep To Dig

Use a bounded evidence pass, not an open-ended audit.

1. **Issue map** - read the Pelvis Shared Key issues to identify distinct
   decision shapes.
2. **Code slice** - read only the functions and data shapes needed to understand
   each decision shape.
3. **Doctrine extraction** - write one compact Code Smell / Trigger /
   Investigation / Finding / Resolution case for each distinct shape.
4. **Stop** - stop when another Pelvis example repeats a shape already covered
   unless it exposes a new key slot, boundary, or related-pattern split.

Inspect Pelvis examples until the doctrine covers these major decision shapes:

- known key with collection scan
- native key slot vs forced ID protocol
- composite relationship key
- ordered list plus derived keyed index
- storage migration risk, as a deferred/high-risk case
- boundary cases where Shared Key is present but another Pattern should carry
  the main teaching burden

Stop before app implementation details take over. For each example, read enough
to answer:

- What identity is already known?
- Where does the identity key live now?
- What key slot should carry it?
- Is this lookup, rendering, filtering, persistence, or interaction?
- Is iteration legitimate?
- Would a keyed source, derived index, or direct DOM address clarify the code?
- Is this really Shared Key, or a different Pattern that consumes Shared Key?

Do not complete the Pelvis refactors before writing this entry. The Pelvis
issues are evidence and proving grounds, not prerequisites for every doctrine
sentence.

## Current Pelvis Evidence Set

The useful depth for #40 is one representative code slice per decision shape.
Prefer the simpler Pelvis examples that need refactor as the compact
before/after material for Shared Key.

- #8 Master Quiz question lookup: `btn.value` already carries the question
  identity, then `QUESTIONS.find(...)` scans for it.
- #10 Master Quiz option lookup: `button.value` and `q.answer` are option keys,
  but the answer option is recovered with `q.options.find(...)`.
- #11 Equivalence link lookup: the code knows `fromId` and `toId`, then scans
  `explanations.links` for the matching relationship.
- #12 Concept map highlighting: the edge list is legitimate for rendering, but
  interaction wants an adjacency lookup by node ID.
- #9 Saved user flashcards: likely Shared Key material, but persistence
  migration makes it a later example, not a first doctrine case.
- #13 Diagnose causal chains: save for #41. It contains Shared Key material,
  but the main refactor is Decorator Factory / Decorator / Active Object.

That is deep enough for the entry. Additional Pelvis searching should happen
only when the draft hits a concrete unanswered question, such as whether a
candidate is legitimate iteration, which key slot carries identity best, or
where Shared Key ends and Decorator Factory begins.

## Example Policy

If the final Pattern entry keeps Wrong/Right examples, use the simple Shared
Key refactors for those examples. "Wrong" should mean "smell-confirmed shape",
not "bad code in all contexts."

Best first examples:

- #8: `QUESTIONS.find(...)` with known `questionId` becomes keyed question
  lookup.
- #10: `q.options.find(...)` with known answer key becomes keyed option lookup
  while preserving display order as needed.
- #11: `links.find(...)` with known endpoint keys becomes a keyed relationship
  map or derived relationship index.

Use #12 as a nuanced example: keep the ordered edge list for rendering, add a
derived adjacency index for keyed interaction.

Do not use #13 as a first Shared Key Wrong/Right example. It is a better #41
case because Shared Key is only one part of the refactor; the interesting
architecture is delegated lazy get-or-create behavior, decorator identity, and
exclusive active drag state.
