# Draft Issue: Add Decorator as a Web XP Pattern (companion to Decorator Factory)

## Summary

Add a short **Decorator** entry to `code-guidelines.md` as the
building-block pattern that Decorator Factory (#41) instantiates.
Called for by #41's own acceptance criteria: *"Add or cross-reference
a concise Decorator building-block Pattern if needed so Delegate
Factory does not carry all Decorator explanation."*

Shared Key (and the sharpening proposed in the Shared Key sharpening
draft) routes the agent toward this entry when an entity has multiple
DOM representations, associated data, and behavior. Encapsulation (#46)
is the principle this entry honors.

## Proposed entry

> **Decorator**
>
> When one domain thing owns related DOM references, state, and
> behavior, wrap it in a type. The decorator is keyed by the shared
> key (#Shared Key). Module code routes events and gets the
> instance; the instance owns the private details.
>
> A Decorator carries:
>
> - the **id** (the shared key — private, exposed via getter)
> - the **DOM refs** the entity owns (canonical element and any
>   non-canonical representations)
> - the **data slice** for this entity (the part of any module-owned
>   keyed table that belongs to this id)
> - the **behavior** the entity supports (`activate()`,
>   `deactivate()`, etc.)
>
> Module code holds no per-entity DOM Maps, no per-entity data
> indices, and no per-entity behavior dispatch — those belong on the
> instance. The module's job is to route events to the right
> instance via Shared Key.
>
> Decorator is almost always paired with **Decorator Factory** (#41),
> which adds the lazy get-or-create surface keyed by id. The
> Decorator entry covers what the instance is; the Decorator Factory
> entry covers how it is created and looked up.

## Placement

**Patterns**, immediately preceding Decorator Factory (#41). Decorator
is the building block; Decorator Factory is the lookup pattern that
mints it.

## Acceptance Criteria

- New short entry "Decorator" added under Patterns in
  `code-guidelines.md`.
- The entry names what a Decorator carries (id, DOM refs, data slice,
  behavior).
- The entry states the routing rule: module routes events; the
  instance owns the private details.
- The entry cross-links to Shared Key, Decorator Factory (#41), and
  Encapsulation (#46).
- Decorator Factory (#41), once landed, links to this entry as the
  building block it instantiates.

## Related

- **Decorator Factory (#41)** — lookup pattern that instantiates this.
- **Encapsulation (#46)** — principle this entry honors.
- **Shared Key** — the contract the decorator's id satisfies. The
  Shared Key sharpening draft routes agents to this entry via the
  entity-first framing.

## Provenance

Same `aic-chain.js` review traced in the Shared Key sharpening draft.
The right answer was an `AicMuscle` Decorator holding id, chain
entry, detail entry, row, circles, and activate/deactivate behavior.
The doctrine had no short Decorator entry to route the agent toward —
#41 covers the factory mechanics but not the building block in a
form a reviewer can scan and apply on its own.
