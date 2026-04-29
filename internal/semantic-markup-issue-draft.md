# Draft Issue: Replace DOM-Light with Semantic Markup (rename + sharpen)

## Summary

The current `code-guidelines.md` DOM-Light rule teaches two claims: use
HTML's built-in features, and keep the DOM small. The first is the stronger
teaching but the rule's title and lead frame it as the second. Rename
DOM-Light to Semantic Markup, lead with the platform-ownership claim, and
absorb the DOM-quantity claim as a corollary.

## Problem

The current DOM-Light rule's first sentence and all three of its examples
(`<form>` with `.reset()`, `<button type="button">`, `<details>`) teach
platform ownership: pick the element or attribute that owns the behavior.
The second paragraph teaches node quantity. The title names the second
teaching, not the first.

A reader applying DOM-Light by name optimizes for fewer nodes. The
platform-ownership teaching is buried.

Quantity does not name the bug. Application code can be DOM-Light and
still maintain a parallel implementation of an element's contract — a
single `<div>` with a JS counter mimicking `<ol>`. The synchronization
layer between application state and the parallel implementation is where
the bug lives.

The HTML spec already prohibits this in negative form:

> Authors must not use elements, attributes, or attribute values for
> purposes other than their appropriate intended semantic purpose.

Doctrine should carry the same intent in positive form, so reviewers and
agents can name the rule before reaching for the spec.

## Proposal

Rename DOM-Light to Semantic Markup. Lead the rule with the
synchronization-layer framing rather than node count:

> If the application is manually rendering, tracking, or syncing what an
> HTML element, attribute, or CSS feature already provides, the
> synchronization layer is the bug. Pick the element, attribute, or CSS
> feature that owns the behavior before writing any code that would
> reproduce it.

Absorb the DOM-quantity advice as a corollary, not a separate rule. Update
references in `code-guidelines.md` and `code-philosophy.md` from
"DOM-Light" to "Semantic Markup."

### Boundaries

- **Custom elements.** Semantic Markup governs behaviors the platform
  already provides. When the platform has no element for a domain
  concept — a concept map, a flashcard, a chain-list step — building a
  custom element is the design move, not a Semantic Markup violation.
- **Augmentation, not replacement.** When the element lacks a behavior
  the application needs, augmentation starts from the element. `<select>`
  cannot style its option list; the augmentation is a popover wired to
  `<select>`'s selection state, not a `<div>` that re-implements
  selection, focus, and keyboard navigation. Replacing the element
  reintroduces the synchronization layer Semantic Markup exists to
  delete.
- **Lower-level primitives when the API does not reach.** When the
  platform's higher-level API is too coarse for the needed control,
  dropping to lower-level primitives is not a violation. `draggable` does
  not provide pixel-precise drop targets; pointer events on the element
  implement the drag behavior the platform's drag API does not reach.
  The rule fires on reproducing what the platform provides, not on
  extending past where it stops.

## Acceptance Criteria

- DOM-Light is renamed to Semantic Markup in `code-guidelines.md`.
- The rule leads with the synchronization-layer framing, not with node
  count.
- The rule names the element, attribute, or CSS feature that owns each
  of these behaviors: ordered numbering (`<ol>` with `::marker`),
  disclosure (`<details>` / `<summary>`), modal stacking with focus trap
  (`<dialog>`), form validation (`<form>` with `required`, `pattern`,
  `type`), button-without-submit (`<button type="button">`), and
  ancestor-of-focus styling (`:focus-within`).
- The rule includes detection signals stated as observable code shapes a
  reviewer can match against a diff.
- The rule includes Boundaries naming custom elements, augmentation, and
  lower-level primitives, each with a concrete example.
- The DOM-quantity claim from the existing DOM-Light text survives inside
  Semantic Markup as a corollary, not as a separate rule.
- Every "DOM-Light" reference in `code-guidelines.md` and
  `code-philosophy.md` is updated to "Semantic Markup."

## Related

- Replaces the current DOM-Light section in `code-guidelines.md`.
- Semantic Markup is a Design Principle.
- Related to #33 (doctrine structure), because the rename affects the
  Design Principles section.

## Provenance

Surfaced when a state-ownership refactor in pelvis (issue #13) left a
stale-numbering UI bug after drag-reorder. Replacing `<ul>` plus manual
`<span class="chain-step-num">` with `<ol>` eliminated the synchronization
that produced the bug.

## Case study: chain-list (pelvis #13)

`<ul>` plus manual numbering → `<ol>`.

- **Bug class eliminated.** Stale-numbering after drag-reorder is
  structurally impossible. Numbers were computed by JS at render time and
  stored in `<span class="chain-step-num">` text; drag mutated DOM order
  without rerunning the render, so spans went stale until the next
  rebuild. `<ol>` derives numbers from live DOM position via `::marker`,
  so reorder = renumber, atomically.
- **Synchronization layer deleted.** No JS code holds, computes, or
  rewrites step indices. Numbering is no longer application state.
- **UX improvement.** Numbers update visibly during drag, not after a
  separate render pass. Reorder feels stable instead of momentarily
  wrong.
- **HTML reduction.** One `<li>` per step replaces `<li>` plus two
  `<span>`s per step.
- **CSS reduction.** The `.chain-step-num` rule is removed; `.chain-list`
  flips from `list-style: none` to `list-style-type: decimal`.
- **JS reduction.** Per-item index loop and `<span>` construction removed
  from `renderChainList`.
