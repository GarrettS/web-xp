# Draft Issue: Add doctrine-grounded four-step review and refactor sequence to enforcement doctrine

## Summary

Web XP should define an explicit four-step review sequence that
distinguishes local cleanup from architectural untangling, weighs
significance and relevance between flagged issues, and produces a
doctrine-rooted prioritized list that the agent and user refine
interactively. Doctrine is the through-line across all four steps.

## Problem

Current doctrine is strong on local patterns and local rules. It is weaker
on the questions that come before and after them:

- What kind of problem is this code in? (classification)
- What ownership is conflated? (untangling)
- Which findings matter most, and how do they relate? (synthesis)
- How does the agent refine the working list with the user against
  doctrine? (interactive review)

A module may involve several concerns at once:

- identity
- state
- behavior
- render
- event handling
- persistence
- translation between concerns, such as DOM IDs to domain keys

Without an explicit sequence, a reviewer or agent can:

- jump too early to a local pattern and make the code worse
- list smells without weighting them, leaving the user to triage
- miss interdependencies — flag both an unnecessary method and a `==`
  inside it, without noting that the `==` is moot once the method is
  removed
- present findings as if all are independent when downstream items depend
  on upstream fixes

The result is a flat smell list, not a prioritized refactoring plan.

## Proposal

Add doctrine for a four-step review and refactor sequence. Doctrine is the
through-line across all four steps: it names what counts as a smell, names
where ownership belongs, governs significance and relevance, and is the
substrate of the interactive review.

### Doctrine application across the four steps

Doctrine is organized into sections — syntax, design principles, design
patterns, and others. Each step consults all relevant sections. There is
no fixed precedence by section: significance, severity, and relevance are
weighed across sections in Step 3. A design-principle violation can
outrank a syntax violation when fixing the principle makes the syntax
problem moot — as in the unnecessary-method/`==` example: removing the
method makes the `==` irrelevant. A syntax violation can also stand on
its own when no upstream fix subsumes it.

### Step 1 — Classify

Identify the concerns present in the module and whether they are already
separated or entangled. Use doctrine to name what counts as a smell.

A concern owns a responsibility when one named place in the module is the
only place that performs it.

### Step 2 — Untangle

When concerns that should be separate are interdependent, decide which
part of the module should own each concern, which functions or objects
need to shrink or split, and which seams must be created before local
patterns can be applied. Use doctrine to name where ownership belongs.

### Step 3 — Apply insight (solo)

Use doctrine and code context to weigh significance, severity, and
relevance between flagged issues. Map interdependencies. Produce a
doctrine-rooted working list:

- ordered top-down by how the refactor should be approached
- with downstream items contextualized to their upstream dependencies — an
  item whose existence depends on an upstream fix names that dependency in
  its entry
- with each item traceable to a doctrine rule

Verification — checking the list for coherence, residual smells, and newly
introduced smells — is part of Step 3, not a separate step.

**Example.** A review surfaces both an unnecessary method and a `==`
inside it.

1. Remove the unnecessary method `processItem()` (`old.js:30-50`).
   Doctrine: Functions — do one thing; if no caller needs this, it is not
   one thing.
2. Replace `==` with `===` at `old.js:42`. Doctrine: Strict Equality.
   Note: moot once item 1 is applied; listed because if item 1 is
   deferred, this smell remains.

### Step 4 — Apply insight (interactive)

Walk the working list with the user. Step 4 reasons from doctrine. When
the user pushes back on an item, the item is re-evaluated against the
rule that motivated it, not against subjective preference. The user
contributes context the agent cannot see — project priorities, intent,
history. The agent keeps reasoning from doctrine. Items are accepted,
deferred, or re-prioritized against the doctrine entry that motivated
them.

The output of Step 4 is the final prioritized list.

## Candidate First-Step Indicators

First-step indicators that suggest architectural untangling rather than
immediate local cleanup:

- one entity's state split across multiple homes
- one identity convention encoded in multiple places
- one function that handles DOM events, state mutation, and rendering at
  once
- a helper exposed only because callers need to route around a boundary
- an instance method that still performs event handling or DOM traversal
- partial pattern scaffolding added while the underlying ownership problem
  remains unresolved

These are review triggers, not automatic findings.

## Source Example

One failure class is pattern scaffolding added on top of unresolved
entanglement. Cleanup cost goes up because the refactor must address both
the original ownership problem and the new intermediate structure layered
on top of it.

The pelvis causal-chain refactor is a useful proving ground for that
failure class.

This rule governs review order. It consults but does not redefine the
local doctrine — Shared Key, Decorator Factory, Event Delegation,
Encapsulation, Native First, and similar entries.

## Acceptance Criteria

- Doctrine distinguishes local cleanup from architectural untangling.
- Doctrine defines all four steps: Classify, Untangle, Apply insight
  (solo), Apply insight (interactive).
- Doctrine names doctrine itself as the through-line across all four
  steps.
- Doctrine specifies that the four-step process consults all sections of
  doctrine — syntax, design principles, design patterns, and others —
  with no fixed precedence by section. Significance, severity, and
  relevance are weighed across sections in Step 3.
- Doctrine specifies that the deliverable from Step 3 is a doctrine-rooted
  working list — ordered top-down by refactor approach, with downstream
  items contextualized to their upstream dependencies, and with each item
  traceable to a doctrine rule.
- Doctrine specifies that Step 4 walks the list with the user and reasons
  from doctrine; subjective preference alone is not a basis for accepting
  or deferring an item.
- Doctrine specifies that the output of Step 4 is the final prioritized
  list.
- Doctrine defines or cross-references first-step indicators for
  entanglement.
- Each first-step indicator names an observable code shape (file
  structure, function signature, or call pattern), not an abstract
  property.
- Doctrine makes clear that triggers identify review candidates, not
  automatic fixes.

## Related

- Related to "Add event-boundary rule: keep browser event objects out of
  instance methods," a Design Principle that the four-step process
  applies.
- Related to "Add Encapsulation as a Web XP Design Principle," a Design
  Principle that the four-step process applies.
- Related to "Call out `PRD/schema first` as default Big Up-Front Design
  (BUFD) and anti-XP," because speculative upfront structure works
  against classification and untangling.
- Related to "Replace DOM-Light with Native First (rename + sharpen),"
  a Design Principle that the four-step process applies.
- Related to #33 (doctrine structure).
- Related to #34 (enforcement-oriented extraction and representation).
- Related to #31 (enforcement must reference doctrine rather than invent a
  separate model).
- Possibly related to #38 if interpretive material must move.
