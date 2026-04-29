# Draft Issue: Add Encapsulation as a Web XP Design Principle

## Summary

Shared Key is the interaction contract that uses a key (string) across DOM,
JS, data, and dispatch. Encapsulation limits what else crosses that
contract.

Web XP should add Encapsulation as an explicit Design Principle. Several
current doctrine concerns rely on it implicitly, but there is no direct
principle that defines the boundary between public contract and internal
implementation.

## Problem

Web XP has rules about identity, naming, DOM access, delegation, and failure
handling, but it lacks a direct doctrine entry for encapsulation.

That leaves recurring questions without a named home:

- what belongs in the public contract
- what should remain internal
- when mutable internal state exposure is a smell
- when an internal convention (ID parser, storage key, pool lookup) leaks
  into the interface
- how to preserve refactor freedom by hiding implementation detail

Without an explicit Encapsulation principle, these concerns get scattered
across pattern entries and resolved inconsistently.

## Proposal

Add Encapsulation as a Design Principle that governs contract surface versus
implementation detail.

The principle should cover:

- expose only what callers actually need
- keep mutable internal state internal unless the contract truly requires
  exposure
- keep internal conventions, such as ID parsers, storage keys, and pool
  lookups, internal unless they are intentionally part of the API
- use closures, private fields, or other suitable mechanisms to enforce the
  boundary

## Governing Statement

> Keep implementation details behind the smallest contract the caller needs.
> Internal state and conventions stay internal unless exposing them is part
> of the design.

## Why This Matters

Encapsulation protects code from unnecessary coupling.

It allows:

- internal refactors without widening the public surface
- better ownership boundaries
- clearer responsibilities
- less accidental misuse of stateful objects and their internals

Without this principle, those concerns keep reappearing as one-off arguments
inside other entries instead of being judged against one rule.

## Worked Example

Pelvis #13 (`study-tool/scripts/diagnose.js`, `CausalChainFactory` and
`CaseStudyFactory`) shows the integration with Shared Key:

- **Symbol KEY** gates construction. `new CausalChain()` from outside the
  factory throws.
- **Closure-scope pool** (`const instances = {}` inside the IIFE) holds
  instances; the pool is not exported, only `getInstance`, `discard`,
  `discardAll`.
- **Private fields** (`#id`, `#steps`, `#order`, `#activeDragItem`) hold
  instance state. Inaccessible from outside.
- **`get id()`** is the only public state accessor — read-only by being a
  getter.
- **Mutation goes through methods**: `advanceVisit()`, `markAnswered()`,
  `commitDrop()`. Callers cannot mutate state directly.

The id (Shared Key) crosses DOM → events → factory → JSON. Nothing else
crosses.

## Acceptance Criteria

- Doctrine adds Encapsulation as a Design Principle.
- The entry distinguishes public contract from implementation detail.
- The entry covers mutable internal state and internal convention exposure.
- The entry allows multiple implementation mechanisms, including closures
  and private fields.
- The Shared Key value crosses the interaction contract; internal state,
  mutation pathways, and construction control do not.

## Related

- Related to "Add event-boundary rule: keep browser event objects out of
  instance methods," because instance methods should not take event-layer
  values as parameters.
- Related to "Add doctrine-grounded four-step review and refactor sequence
  to enforcement doctrine," because untangling often turns on what belongs
  inside a contract versus outside it.
- Related to #41 (Decorator Factory), because constructor/pool privacy and
  instance-method boundaries rely on encapsulation.
- Related to #33 (doctrine structure).
- Potentially related to #36 (Single Responsibility), depending on how
  module and object boundaries are ultimately divided.
