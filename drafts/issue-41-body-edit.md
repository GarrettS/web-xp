## Summary

Web XP should add **Decorator Factory** as a named Pattern.

The pattern is related to Shared Key, Decorator, and Event Delegation, but it is not the same thing as any one of them. Shared Key makes identity explicit across DOM, data, and behavior. Decorator associates an object type with a keyed Element or UI object. Decorator Factory adds a lazy get-or-create layer reached from an event-driven context: one behavior object per keyed UI object, created on demand from a delegated event path.

This issue is related to #40 and should feed #33's pattern-structure work.

## Goal

Develop the Decorator Factory doctrine entry into pattern material that can guide humans, agents, and future tooling.

The entry should use the same diagnostic shape being developed in #40:

1. **Code Smell** — detectable code shape that may indicate missing lazy keyed decoration
2. **Trigger** — mechanical first-pass indicator
3. **Investigation** — context questions the reviewer or agent must answer
4. **Finding** — when the smell becomes a real Decorator Factory issue
5. **Resolution** — context-appropriate change or explicit non-change

This distinction matters for #34: a trigger flags code for review; it does not declare a violation or prescribe an automatic fix.

## Candidate Doctrine Outline

### Governing Statement

Use `getById(id)` to lazily create or retrieve one behavior object for a keyed Element or UI object when that object owns per-instance behavior/state and interaction begins from an event path.

The decorated Element or UI object's `id` is the identity key. The decorator stores the same `id`. Delegated events supply the element or key. `getById(id)` creates or retrieves the decorator.

Hide the constructor and instance pool. Expose only the factory operation.

Store the element ID rather than a long-lived DOM reference unless the element lifetime is stable. The decorator can resolve the live element with `document.getElementById(this.id)` when needed.

### Core Distinctions

- **Decorator** — an object type associated with a keyed Element or UI object, usually storing the same `id`.
- **Decorator Factory** — the pattern that creates or retrieves one decorator from a delegated/event-driven demand path.
- **Factory** — the public `getById(id)` surface that creates or retrieves the decorator.
- **Instance pool** — private keyed object storing one decorator per identity key.
- **Event path** — the delegated event route that supplies the decorated Element/UI object or its key.

### Code Smells

Potential cases the entry should cover:

- Eagerly initializing per-element behavior objects for many keyed elements.
- Adding per-element listeners where a delegated event can supply the keyed element.
- Rebuilding per-element state on each interaction instead of retrieving one object by key.
- Searching for an active behavior object instead of addressing it by element ID.
- Holding long-lived DOM references where storing the element ID would be safer.
- Using a generic factory abstraction when a small local get-or-create factory would do.

### Triggers

Candidate mechanical first-pass indicators:

- `forEach(... addEventListener(...))` or listeners attached inside a render/build loop.
- `initX(id, state)` called once per generated keyed element.
- repeated `new X(...)` for elements that already have stable IDs.
- object pools or arrays indexed by generated element position instead of element ID.
- event handlers that can resolve an element with `closest(...)` but still rely on eager setup.

These are review triggers, not automatic violations.

### Investigation

Questions the reviewer or agent should answer:

- Does each decorated element have stable app-owned identity?
- Does behavior/state belong to one element instance?
- Can a delegated event supply the element or key?
- Is up-front initialization avoidable?
- Does the behavior need at most one object per element?
- Should the object store the element ID instead of a long-lived DOM reference?
- Would a plain delegated handler be enough without a decorator?
- Would adding a decorator improve cohesion, or add unnecessary abstraction?

### Finding

This becomes a Decorator Factory finding when:

- per-element behavior/state exists,
- each element has stable identity,
- the app eagerly initializes behavior or listeners for all instances,
- interaction can instead resolve the keyed element from a delegated event path,
- and one lazy behavior object per element would clarify ownership without adding unnecessary abstraction.

### Resolution

Use a private constructor and private instance pool. Expose `getById(id)` as the explicit get-or-create operation.

The decorator stores `this.id` matching the decorated element's ID. The factory creates at most one decorator per key. The delegated handler resolves the element by class/selector, then calls the factory with the element ID.

If the investigation shows that no per-element behavior/state is needed, keep a plain delegated handler instead. If all elements must be initialized immediately for a real reason, document that reason and do not force the pattern.

## Pattern Relationships

- **Decorator** — the building-block pattern: an object type associated with a keyed Element or UI object.
- **Shared Key** — required. The element/UI-object ID, decorator ID, and factory pool key align.
- **Event Delegation** — commonly supplies the keyed element from a bubbled event path.
- **Active Object** — often appears inside the decorator when it stores the current active descendant or interaction state directly.
- **Ubiquitous Language** — decorator and element names must describe the domain behavior, not generic wrapper mechanics.
- **YAGNI / DOM-Light** — use this only when per-element behavior/state exists. If a plain delegated handler is enough, do not add a decorator.

## Source Example

Pelvis #13 is the current proving-ground refactor:

- https://github.com/GarrettS/pelvis/issues/13

It should produce a real example of causal-chain drag behavior using a keyed decorator created on first interaction. Do not bake the Pelvis implementation sketch into doctrine until the refactor proves out.

APE / Noisebridge Factory material is useful provenance for issue discussion, but the doctrine should extract only the current Web XP pattern and avoid generic factory machinery.

## Acceptance Criteria

- Add a concise pattern entry to `code-guidelines.md`.
- Add or cross-reference a concise **Decorator** building-block Pattern if needed so Decorator Factory does not carry all Decorator explanation.
- The entry distinguishes Decorator Factory from Shared Key, Decorator, and Event Delegation.
- The entry uses Code Smell / Trigger / Investigation / Finding / Resolution structure.
- The entry states that the constructor and instance pool should be private.
- The entry states that the decorator `id` should match the decorated Element/UI object's identity key.
- The entry explains when this pattern is overbuilt and a plain delegated handler is enough.
- Related Rules / Related Sections are explicitly listed in the final doctrine entry.
- Related Rules should include at least Decorator, Shared Key, Event Delegation, Active Object, Ubiquitous Language, and DOM-Light / YAGNI where relevant.
- Link to the Pelvis #13 example after the refactor proves out.

