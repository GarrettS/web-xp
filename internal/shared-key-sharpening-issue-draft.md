# Draft Issue: Sharpen Shared Key — layer discernment, entity-first framing, multi-element entities

## Summary

Four amendments to the existing Shared Key entry. The existing entry
already covers `data-*` as last resort (Element Key Slots), Forced
Key, Misplaced Key, Array Position Instead of Key, and references
Decorator Factory inline. The amendments fill three real gaps:

1. **Layer Discernment** — promote the Module Ownership sentence
   ("each layer keeps its internals encapsulated") into an explicit
   three-layer structural frame.
2. **Entity-first framing** — ask *"is there a Decorator that should
   already hold both?"* before recovering an element from an id.
3. **Multi-element entities** — the canonical-element rule for
   entities with more than one DOM representation. Existing entries
   cover one element / one slot / data shape; none cover one entity
   / multiple elements.
4. **JS Maps keyed by DOM elements** — addendum to Element Key Slots
   naming this as a non–key-slot smell.

Plus a one-line thought smell at the end.

## Dependencies (blocking)

Cross-links to entries that don't exist in `code-guidelines.md` yet:

- **Decorator** — companion building-block entry (called for by
  #41's acceptance criteria).
- **Decorator Factory (#41)** — already referenced inline in Array
  Position Instead of Key; needs its own entry.
- **Encapsulation (#46)** — principle Module Ownership already
  implies.

Suggested order: Encapsulation → Decorator → Decorator Factory →
this.

## Proposed additions

### Layer discernment (leads the entry)

> Shared Key coordinates one key across three layers, each with its
> own ownership rules.
>
> - **DOM layer**
>   - DOM identity (`id`, `value`, `name`)
>   - semantic element / attribute choice (#47 Semantic Markup)
>   - event target resolution (`closest()`, `querySelector`,
>     delegated handlers)
> - **Module / runtime layer**
>   - registries
>   - reverse lookup structures
>   - factory / decorator retrieval (#Decorator Factory)
> - **Decorator / wrapper layer**
>   - one domain thing's private state and behavior, bounded by
>     Encapsulation (#46)
>
> The same key appears in each layer — separation that supports
> encapsulation and interaction.

### Entity-first framing (follows Layer Discernment)

> Before asking *"how do I recover the element from this id?"*, ask:
> *"Is there a Decorator (#Decorator Factory) that should already
> hold both — the id, its DOM representations, and its associated
> data?"*
>
> Free functions that take an id and look up elements and data
> separately are a sign that the Decorator is missing.

### Multi-element entities (near Forced Key / Misplaced Key)

> When one entity has more than one DOM representation, only one
> element can carry `id = key`. Choose the entity's **canonical
> element** (row, card, panel) and put the key there. Other
> representations are reached through the Decorator.
>
> Delegated events on a non-canonical element resolve to the entity
> by:
>
> - `closest()` to the canonical element when it's an ancestor;
> - a parallel id scheme (e.g., `id="muscle-anatomy-{id}"` sharing
>   the suffix);
> - the Decorator's reverse `WeakMap` when the relationship is
>   non-structural.

### JS Maps keyed by DOM elements (addendum to Element Key Slots)

> Maps keyed by DOM elements duplicate the DOM's own indexing and
> are not a key slot. If the entity has multiple representations,
> the answer is a Decorator (see Multi-Element Entities), not a
> Map.

### Thought smell (one-line check at the end)

> If you find yourself asking *"how do I recover the element from
> this id?"*, ask first: *"is there a Decorator that should already
> hold both?"*

## Cross-links

- **Decorator** — the entity-level move.
- **Decorator Factory (#41)** — mints the Decorator by id.
- **Encapsulation (#46)** — what gives the layers their boundaries.

## Acceptance Criteria

- New Layer Discernment subsection leads the entry.
- New Entity-First Framing subsection sits between Layer Discernment
  and the existing Rule.
- New Multi-Element Entities subsection sits near Forced Key /
  Misplaced Key.
- Element Key Slots gains the Maps-keyed-by-DOM-elements addendum.
- Thought smell one-liner at the end of the entry.
- Cross-links to Decorator, Decorator Factory (#41), and
  Encapsulation (#46).

## Related

- #41, #46, and the not-yet-filed Decorator companion are blocking.
- #37 (native element semantics carry the key) is adjacent and can
  land independently.

## Provenance

`aic-chain.js` review: one muscle entity with three DOM
representations (panel row + two overlay circles) and three JS Maps
bridging them. The agent caught the Forced Key violation but
mis-corrected toward module-state carry, then `data-*` on every
element. The doctrine had no entry for the multi-element-entity
case, no entity-first prompt, and no enumeration of the three
layers — so "Shared Key" parsed as "find a place for the key."
