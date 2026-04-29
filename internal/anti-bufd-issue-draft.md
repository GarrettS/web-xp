# Draft Issue: Call out `PRD/schema first` as default Big Up-Front Design (BUFD) and anti-XP

## Summary

Web XP should state plainly and early that `PRD first, schema first` as a
default development method is Big Up-Front Design (BUFD) and therefore
anti-XP.

Web XP already centers small commits, continuous refactoring, tight feedback
loops, and the simplest thing that could possibly work. But the doctrine does
not yet confront the current AI-era "best practice" directly enough. That
leaves too much room for speculative upfront design to present itself as
discipline.

## Problem

Current AI workflow advice often recommends:

- write a PRD first
- define the schema first
- settle structure before touching code

As a default method, that is BUFD. It decides too much structure before code
and refactoring have exposed the real seams, constraints, and ownership
boundaries.

This is not the same thing as:

- recording a project decision already made, such as hash routing or JSON data
  files
- documenting content authority already chosen
- writing down an API or file contract the code already depends on
- updating a project overlay file such as `prd/project.md`

Those documents record decisions already made and constraints already
discovered. The problem is writing down structure, schemas, or abstractions
the code does not yet exhibit, then treating that speculation as the normal
starting move.

Without an explicit doctrine statement, agents and users can mistake upfront
PRD/schema work for rigor when it often produces premature abstraction, drift,
and structure that later code must work around.

## Proposal

Add a concise doctrine statement that:

- names `PRD/schema first` as BUFD when used as the default workflow
- states that BUFD is anti-XP
- distinguishes speculative upfront design from documents that record
  decisions already made and constraints already discovered
- points users toward concrete artifacts such as a `prd/project.md` overlay, a
  content-authority note, or an existing API/file contract the code already
  implements

The goal is not to ban all documentation. The goal is to distinguish documents
that record what is currently true from documents that speculate too far ahead
of the code.

## Candidate Rule

> `PRD first, schema first` as a default method is BUFD. In Web XP, code and
> refactoring discover architecture; documents record current truth,
> constraints, and explicit decisions rather than pre-owning the design.

## Why This Matters

This matters more in AI-assisted workflows than in human-only workflows.

A human may be slowed by speculative upfront design. An agent can amplify it
quickly:

- more premature structure
- more guessed abstractions
- more schemas treated as architecture
- more drift when reality changes

If Web XP exists to keep speed from dissolving into slop, it needs to reject
one of the main ways slop is rationalized.

## Scope

This issue is about doctrine and positioning, not about banning all planning
artifacts.

It should not claim that:

- all PRDs are wrong
- all schemas are wrong
- no design notes should exist before code

It should claim that speculative `PRD/schema first` as the default development
method is anti-XP, while documents that record decisions already made and
constraints already discovered remain valid.

## Acceptance Criteria

- Doctrine explicitly names `PRD/schema first` as BUFD when used as the default
  workflow.
- Doctrine explicitly states that this is anti-XP.
- Doctrine distinguishes documents that define structure the code does not yet
  exhibit from documents that record decisions already made and constraints
  already discovered.
- Doctrine points to concrete artifacts such as a project overlay file,
  content-authority note, or existing API/file contract as the XP-compatible
  alternative.

## Related

- Related to "Add pre-refactor scope classification and architectural
  untangling to enforcement doctrine," because XP-style discovery and
  classification work against the same upfront-design pressure.
- Related to #33 (doctrine structure), because the anti-BUFD statement needs a
  stable place in doctrine.
- Related to #38 (interpretive doctrine restructuring) if longer rationale is
  moved or compressed.
