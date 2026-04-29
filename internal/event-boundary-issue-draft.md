# Draft Issue: Add event-boundary rule: keep events and listeners scoped to the event layer

## Summary

Web XP should add a rule that the event layer owns both the event object
and the listener registration. Browser event objects stay in the event
layer and do not pass into instance methods. Event listeners are attached
once at module init and do not accumulate inside repeatable build
functions.

## Problem

A recurring smell is code like this:

```js
widget.reorderFromEvent(event, listEl);
```

Here the browser event object is passed into an instance method.

That makes the instance method depend on the browser event system instead
of on the behavior it is supposed to own. It blurs the boundary between:

- event handling
- instance behavior
- domain logic

It also turns a temporal browser object into part of the instance method's
API. That makes the method harder to name, harder to reason about, and
easier to call from the wrong layer.

A second smell is the listener attached inside a function that may run
more than once:

```js
function buildCausalChains() {
  // ... DOM construction ...

  wrap.addEventListener('click', handleClick);
  wrap.addEventListener('pointerdown', handlePointerDown);
  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') cancelActiveDrag();
  });
}
```

If `buildCausalChains` runs more than once, every wrap listener accumulates
and each click fires N handlers. The `document` keydown handler is worse —
it leaks to a global host that survives any local container teardown,
holding the closure forever.

## Proposal

Add a doctrine rule that:

- browser event objects stay within the event layer
- handlers extract the needed values or references
- instance methods receive those extracted inputs, not the event object
  itself
- listeners are attached once at module init, not inside functions that
  may be called more than once
- listeners on `document` and `window` are restricted to module init —
  these hosts outlive any local container, so leaks persist for the
  page's lifetime

Preferred direction:

```js
container.addEventListener('dragover', (event) => {
  event.preventDefault();
  const listEl = event.target.closest('.item-list');
  if (!listEl) return;

  const widget = getWidgetByElement(listEl);
  widget.reorderToward(event.clientY, listEl);
});
```

Not:

```js
widget.reorderFromEvent(event, listEl);
```

## Boundary Clarification

Passing an event to a function called only from the event layer is still
event-layer code. Passing an event into an instance method changes the
instance method's API and leaks browser mechanics into implementation
code.

Allowed:

- passing the event to another event-layer function
- extracting values from the event and passing those values onward
- delegated event handling as part of event-layer control flow
- attaching listeners once at module-level init or inside `init` paired
  with a separate `reset` (`init` may call `reset`; `reset` must never
  call `init`)

Discouraged or review candidate:

- passing the browser event object into instance methods
- passing the browser event object into domain methods
- making browser event objects part of a stateful object's public API
- `addEventListener` inside a `build*`, `render*`, or other function the
  caller may run more than once
- `document.addEventListener` or `window.addEventListener` outside
  module-level init

## Why This Matters

Event objects are temporal browser values. Persisting them past the
handler has historically been unsafe: later reads may be invalid, and
long-held references can keep stale DOM relationships alive.

Listeners have the same lifetime concern at the registration end. A
listener attached inside a function that runs more than once accumulates —
every call adds another handler to the same target, so each event fires
N handlers. Listeners attached to `document` or `window` outlive the
local DOM the call was scoped to, holding the closure they captured for
the rest of the page's lifetime.

More importantly, event objects describe how input arrived, not what the
instance should do. An instance method should take semantic inputs such
as a coordinate, an element, a direction, or a key. If it takes an event
object instead, the event layer has leaked into the instance method's API.

## Acceptance Criteria

- Doctrine adds a binding rule that keeps browser event objects within
  the event layer.
- The rule explicitly allows event-layer functions while discouraging
  event objects in instance or domain APIs.
- Examples distinguish event-layer functions from instance methods.
- The examples include at least one allowed shape and one discouraged
  shape.
- Listeners are attached once at module init. A function that may be
  called more than once does not contain `addEventListener` for any
  persistent target. Reason: listeners accumulate; each call adds another
  handler to the same target.
- `document.addEventListener` and `window.addEventListener` are
  restricted to module init. Reason: these hosts outlive any local
  container, so leaks persist for the page's lifetime.
- The rule is framed as a boundary rule covering both event-object scope
  and listener lifetime.

## Related

- Related to "Add doctrine-grounded four-step review and refactor
  sequence to enforcement doctrine," because event-boundary is one of
  the rules that sequence applies during review.
- Related to "Add Encapsulation as a Web XP Design Principle," because
  an instance method should not take browser event objects as part of
  its API.
- Related to #41 (Decorator Factory), but should not be absorbed by it.
- Related to #33 (doctrine structure).
