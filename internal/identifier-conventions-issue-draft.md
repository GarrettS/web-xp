# Draft Issue: Restructure Identifier Conventions — split run-on rule, expand boolean copulas

## Summary

The Identifier Conventions section in `code-guidelines.md` currently packs five
distinct rules into a single run-on bullet at line 544. The boolean-prefix list
also omits copulas that arise naturally in code, especially `are` for plural
booleans and `should` for policy or intent.

## Problem

Current text (`code-guidelines.md:544`):

> **Naming conventions.** Constants: `UPPER_SNAKE_CASE`. Functions/variables:
> `camelCase`. Classes: `PascalCase`. Booleans prefixed: `is`/`has`/`does`/`can`.
> Event handler functions: `[object][EventName]Handler` (e.g.
> `itemClickHandler`, `formSubmitHandler`). Functions that process results but
> do not receive an event object are not handlers — name them by what they do
> (e.g. `validateInput`, `saveRecord`). Give each identifier a meaningful name
> from the project's ubiquitous language.

Problems:

- Case conventions, boolean prefixes, handler naming, non-handler naming, and
  ubiquitous-language guidance are mashed into one bullet.
- `Identifier naming.` repeats the ubiquitous-language point immediately below.
- `is`/`has`/`does`/`can` does not cover common boolean names such as
  `areItemsLoaded` or `shouldRetry`.
- Predicate methods such as `includes`, `contains`, `matches`, and
  `startsWith` read naturally without a copula, but the rule does not say so.

## Target shape

Replace the run-on bullet with discrete sub-bullets:

- **Case.** Constants `UPPER_SNAKE_CASE`. Functions and variables `camelCase`.
  Classes `PascalCase`.
- **Booleans.** Prefix with a copula that makes the name read as a yes/no
  question: `is`, `has`, `does`, `can`, `are`, `should`.
- **Predicate methods.** Methods that read as questions without a copula
  (`includes`, `contains`, `matches`, `startsWith`) are idiomatic and do not
  need a prefix.
- **Event handlers.** Handler functions follow `[object][EventName]Handler`
  (e.g. `itemClickHandler`, `formSubmitHandler`). The handler is the function
  that receives the event object.
- **Non-handlers.** Functions that process results but do not receive an event
  object are not handlers. Name them by what they do (`validateInput`,
  `saveRecord`).
- **Domain language.** Cross-reference `Identifier naming` instead of repeating
  it.

## Acceptance criteria

- `code-guidelines.md` Identifier Conventions section is split into discrete
  sub-bullets covering: case, booleans, predicate methods, event handlers,
  non-handlers, domain language.
- Boolean copula list includes `are` and `should`.
- Boolean copula list does not expand to `will` or `did`.
- Predicate-method exception is stated.
- No content regression: every rule currently encoded at line 544 still
  appears, just in its own bullet.
- `Identifier naming` (line 545) is reviewed for overlap and either trimmed
  or cross-referenced.

## Out of scope

- Changing case conventions themselves.
- Renaming the handler suffix pattern.
- Lint rules. The doctrine encodes the convention; mechanical enforcement is
  a separate concern.
