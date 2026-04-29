# Draft Issue: Sharpen Template and cloneNode

## Summary

The current Template and cloneNode entry says "in a loop" without
defining what counts as a loop, and does not cross-link to Semantic
Markup (#47). Reviewers and agents read "loop" as `for`/`while` and
miss `.forEach`/`.map`/`for…of` — and miss them again when the
loop body delegates to a named helper. Tighten the trigger, name
the major loop forms, state that delegating to a helper does not
exempt the helper, and link upward to Semantic Markup as the rule
to check first.

## Problem

Two observed misses:

1. **"Loop" read literally.** Reviewers scan for `for`/`while`. They
   skip `.forEach`, `.map`, `for…of`, `for…in`, and recursive
   renderers that call themselves per node.
2. **Indirect call escapes the rule.**
   `items.forEach((item) => buildCard(item))` — `buildCard` is a
   loop body. If `buildCard` builds a fixed structure with
   `createElement`, the rule applies to `buildCard`. The rule
   currently reads as if extracting the body to a named function
   makes the rule stop firing.

Separately, the rule does not say "check Semantic Markup first."
A reviewer applying it literally will template+clone a
hand-rolled `<details>` instead of using the native element.

## Proposed revision

Replace the current entry with:

> **Template and cloneNode**
>
> Check Semantic Markup (#47) first: if HTML elements own the
> structure (e.g. `<details>` + `<summary>`, `<dialog>`,
> `<ol>` + `<li>`, `<select>` + `<option>`), use them and stop.
>
> Otherwise, when a loop builds a fixed element structure, build
> one template element outside the loop and `cloneNode(false)` per
> iteration, setting only the per-instance values.
>
> "Loop" includes `for`, `while`, `for…of`, `for…in`, `.forEach`,
> `.map` (and `.flatMap` / `.reduce` when used to build elements),
> and recursive renderers called per node. Delegating the body to
> a named helper does not exempt the helper:
> `items.forEach((item) => buildCard(item))` makes `buildCard` a
> loop body, and the rule applies to `buildCard`.
>
> Avoids redundant `createElement` / `setAttribute` /
> `classList.add` calls per iteration, and concentrates structural
> changes in one place instead of spreading them across each
> per-instance assignment.

## Placement

Keep in **Patterns**, where it sits today. It is an implementation
tactic, not a Design Principle. The upward link to Semantic Markup
(a Principle) mirrors existing Pattern→Principle relationships in
the doctrine. Semantic Markup (#47) should also gain a downward
link to this rule as the next step once HTML-element deferral has
been ruled out.

## Acceptance Criteria

- The Template and cloneNode entry opens by deferring to Semantic
  Markup (#47).
- The entry names `for`, `while`, `for…of`, `for…in`, `.forEach`,
  `.map`, and recursive renderers as forms of "loop."
- The entry states that delegating the body to a named helper does
  not exempt the helper.
- The entry remains in the Patterns section.
- Semantic Markup (#47) gains a reference to Template and
  cloneNode as the next-step rule when no HTML elements fit.

## Related

- Depends on #47 (Semantic Markup) for the upward link target by
  name.
- Replaces the current Template and cloneNode entry in
  `code-guidelines.md`.

## Provenance

A recursive `renderNode` helper built the same `div` + `button` +
`div` structure on every recursive call. Both human and agent
review missed two doctrine entries:

1. Semantic Markup — the structure is a disclosure widget;
   `<details>` and `<summary>` are the correct HTML elements.
2. Template and cloneNode — even without the disclosure rewrite,
   the function builds a fixed structure per iteration. The rule
   did not fire because the iteration was a `.forEach` callback
   that recursed, not a `for` loop.
