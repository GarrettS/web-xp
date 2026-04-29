# Code Guidelines 

This is Web XP’s code doctrine for humans and agents, supported by interpretive context, examples, and rationale in `code-philosophy.md`.

These rules draw on Google’s [JavaScript](https://google.github.io/styleguide/jsguide.html) and [HTML/CSS](https://google.github.io/styleguide/htmlcssguide.html) style guides, comp.lang.javascript
[Code Guidelines](https://web.archive.org/web/20240805191807/http://jibbering.com/faq/notes/code-guidelines/).

---

## Design Principles

### Fail-Safe

**No uncaught errors. No silent failure paths. Every failure must resolve to a defined safe outcome.**

#### User-initiated vs. Background

- **User-initiated** — the user clicked Save, submitted a form, requested data. Failure must be visible.
- **Background enhancement** — UX improvement not required for user's current task. Don't alert user with background failure noise; explain the silent failure in a code-comment. Examples: eager state persistence or data preloads to enhance future interaction. This is often preferable to polyfills, which add code that soon becomes obsolete.

**Runtime vs User errors:**

- **Runtime failures** — network errors, parse failures, storage quota exceeded, missing resources. Catch at the source. Do not let upstream failures cascade into downstream reference errors.
- **User errors** — invalid input, out-of-range values, malformed data. Validate, give clear feedback, and do not proceed with bad data.

**Messages are shared vocabulary.** Use plain, specific, [ubiquitous](#ubiquitous-language) language in error messages. Distinguish failure cases so users understand what happened, and so the team can assess and fix reported errors.

- **User outcome** — what went wrong, in the app's language. MUST be shown.
- **Diagnostic label** — short precise error name, for accurate troubleshooting. MAY follow the user outcome with non-sensitive context such as a filename. Caught errors SHOULD use failed operation + [`error.name`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error/name) or [`DOMException.name`](https://developer.mozilla.org/en-US/docs/Web/API/DOMException/name).
- **Raw detail** — raw `error.message`, stack trace, object dumps, or URLs. MUST NOT be shown by default.
- **Secrets** — passwords, tokens, keys, and credentials. MUST NOT be shown.

Do not add error-handling abstraction the handler does not need.

#### Violations

**Uncaught runtime failure**

**Wrong** (no error path):

```javascript
localStorage.setItem(key, JSON.stringify(data));
```

**Code smell:** fallible runtime operation with no error path.

- Error propagates and breaks control flow.
- App may continue from a broken state or stop before defining a safe outcome.

**Undifferentiated error handling**

**Wrong** (catch-all):

```javascript
try {
  localStorage.setItem(key, JSON.stringify(data));
} catch (e) {
  showError("Could not save.");
}
```

**Code smell:** one `catch` covering operations with different safe outcomes.

- Generic message: user can't act on it, support can't help, QA can't triage.
- Distinct failure modes (`JSON.stringify`, `setItem`) collapsed into one outcome.

**Right**:

```javascript
let serialized;
try {
  serialized = JSON.stringify(data);
} catch (serializeError) {
  showError(
    "Couldn't save flashcard: data could not be serialized: "
      + serializeError.name);
  return;
}
try {
  localStorage.setItem(key, serialized);
} catch (storageWriteError) {
  showError(
    "Couldn't save flashcard to browser storage: " + storageWriteError.name);
}
```

**Missing HTTP error differentiation**

**Wrong:**

```javascript
let response;
try {
  response = await fetch(url);
} catch (networkError) {
  showError("Network error — could not reach server.");
  return;
}
showMessage("Loaded.");
```

**Pattern:** `\bfetch\(` — verify `response.ok` is checked before the success path.

**Right**:

```javascript
let response;
try {
  response = await fetch(url);
} catch (networkError) {
  showError("Network error — could not reach server.");
  return;
}
if (!response.ok) {
  showError("Server returned " + response.status + ".");
  return;
}
```

**Empty catch, no comment**

**Wrong:**

```javascript
catch (e) {}
```

**Pattern:** `catch\s*\(\w*\)\s*\{\s*\}`

Suppressed error with no explanation. Indistinguishable from a bug. Next developer adds handling that may alert the user about a background failure they never needed to see.

**Right:**

```javascript
catch (anyError) {
  // Background save — not user-initiated.
  // App functions without persistence; user loses streak data only.
}
```

#### Exceptions

- **Empty catch**: background operation with a degradation comment explaining what the user loses.
- **Handled elsewhere**: delegated to a caller or callee that distinguishes error types.
- **Raw detail**: may appear only behind explicit disclosure such as `<details>`, and only when sanitized, bounded, and useful.

#### Related Rules / Related Sections

[[related rules / related sections]]

### Ubiquitous Language

#### Governing Statement

Use the app domain’s language across the user interface, identifiers, class names, selectors, filenames, methods, DOM IDs, JSON keys, PRD/spec language, tests, and related documentation. If the user says "concept map," the code says `conceptMap` — not `cmap`, `graph`, or `diagram`. If the authoritative domain reference uses an abbreviation, the data may store it and the UI expands it at render time. Use domain abbreviations, not programmer shorthand.

#### Core Distinctions

This principle unifies:
- **Identifier naming** — materially accurate names from the domain
- **CSS selectors** — semantic names from the domain
- **Shared Key** — module-owned prefixes and IDs that name the domain concept
- **Module Cohesion** — file names that describe the domain responsibility

#### Violations

Mismatch between domain language and code language is a defect. It inserts a translation layer into reading, debugging, and maintenance, increasing the chance that the developer's mental model drifts from the actual system. Features must be discoverable by searching for the same words the user, PRD, and authoritative domain reference use.

#### Reference Examples

- **[Good Names](code-philosophy.md#good-names)** — examples and interpretive guidance on material-accuracy naming and grepability.
- **[Shared Key: Why IDs Are the Architecture](code-philosophy.md#shared-key-why-ids-are-the-architecture)** — examples of domain naming carried across IDs, dispatch, and data keys.

#### Related Rules / Related Sections

- **[Shared Key](#shared-key)** — use the same domain terms in data keys, DOM IDs, and lookups.
- **[Module Cohesion](#module-cohesion)** — use domain terms in module names and file names.
- **[Good Names](code-philosophy.md#good-names)** — interpretive guidance on material-accuracy naming and grepability.

### Module Cohesion

Each module owns one domain concept. Name the module after what it does: `quiz.js`, `flashcards.js`, `navigation.js`. If the name describes a role instead of a domain concept, it is a junk drawer — `utils.js`, `helpers.js`, `tools.js`, `misc.js`, `common.js` are common examples, but any name that could apply to any project instead of *this* project violates the principle. If a function does not belong in an existing module, create a new module with a specific name. When a module grows to cover multiple concerns, split it.

### Minimize Traversal Scope

Do not search a broader part of the DOM than the task requires. When the element, ancestor, or key is already known, address it directly instead of scanning. When search is necessary, constrain it to the smallest subtree or event path that can contain the answer.

- **[Active Object](#active-object)** — the element is known; address it directly.
- **[Event Delegation](#event-delegation)** — the ancestor is known; resolve within the event path.
- **[Shared Key](#shared-key)** — the key is known; look up by ID, not by query.
- **[DOM-Light](#dom-light)** — fewer nodes means shorter traversals.

### DOM-Light

Favor source HTML over JS-generated markup. Do not use JavaScript to solve what HTML already does natively. Examples:
- `<form>` with `.reset()` instead of looping through inputs to clear them manually
- `<button type="button">` instead of `<button>` with `preventDefault` to avoid submission
- `<details>` instead of a `div` with JS toggle logic

Keep the DOM to the simplest semantic structure necessary — more markup means more bytes, more parsing, and a larger tree for scripts to traverse. When creating elements dynamically, use `createElement`.

### Directory Structure

Separate app code from dev tools. App code lives in designated directories by type (scripts, styles, data, assets). Dev tools live in their own directory, not mixed with app code. The project root contains only files that must be there (entry HTML, files with browser scope constraints) and project documentation.

### Progressive Enhancement

Use progressive enhancement sparingly, and generally avoid polyfills. Degrade gracefully; don't try hamfisted approaches to force it to work in all browsers.

### Explicit Asset Lists

When code enumerates project assets — precache manifests, build tool file lists, resource loaders — each entry must be individually justified by an app code reference. Dev tools and documentation are not app code; a reference from a dev tool does not justify inclusion in an asset list. Never glob-include a directory. An asset list is a contract: every entry is used by the running app, every app-used asset is listed. When files are added or removed, update asset lists in the same commit.

### Design Tokens

**Repeated values are named once.** When a CSS value — color, duration, shadow, spacing step, font stack — appears in more than one rule, define it as a custom property on `:root`. Reference the token everywhere; never hardcode the raw value outside `:root`.

This is the CSS form of "no magic numbers." A hardcoded `0.12s` in twelve files is twelve places to update and twelve chances to drift. A token `--dur-fast: 120ms` is one.

**Name tokens by role, not by value.** Use a tiered scale that communicates intent: `--dur-fast` / `--dur-normal`, `--box-shadow-sm` / `--box-shadow-md`. The name describes where the token sits on a severity or size axis. The concrete value can change without renaming, and a reader understands the intent without inspecting the value.

❌ Named by value — the name becomes a lie when the value changes:
```css
--shadow-2px: 0 2px 6px rgba(0, 0, 0, 0.15);
--duration-120: 120ms;
```

✅ Named by role — stable across value changes:
```css
--box-shadow-sm: 0 0.05rem 0.15rem rgba(0, 0, 0, 0.06);
--dur-fast: 120ms;
```

**Dark mode is a token concern.** Define both light and dark values for every token in the same file — light on `:root`, dark in `@media (prefers-color-scheme: dark)`. Components consume tokens; they never need their own dark-mode media query. If a component needs a dark-mode override, a token is missing.

---

## Patterns

Implementation patterns for DOM-heavy vanilla JS applications.

### Event Delegation

Attach one handler to a stable ancestor and inspect `event.target`. This scales, avoids initialization loops, and works for dynamically added elements.

Know the event target ([Minimize Traversal Scope](#minimize-traversal-scope)). Use `event.target` when the event fires on the actionable element. For events such as `dragstart` that fire on the actionable element itself, use `event.target` directly when no nested draggable descendant can be the target. When nested markup can receive the event and upward resolution is needed, use `closest()` to find the actionable ancestor. Attach the listener to the nearest common ancestor, not a distant parent. The event path defines the search space; do not expand it.

❌ Per-element listeners in a build function — accumulate on reset, create N identical closures:
```javascript
function buildList(items) {
  ul.innerHTML = "";
  items.forEach((item) => {
    const li = document.createElement("li");
    li.addEventListener("click", () => handleItem(item));
    ul.appendChild(li);
  });
}
```

❌ Shared function, but still per-element — no accumulation, but N bindings for one concern:
```javascript
function buildList(items) {
  ul.innerHTML = "";
  items.forEach((item) => {
    const li = document.createElement("li");
    li.addEventListener("click", itemClickHandler);
    ul.appendChild(li);
  });
}
```

✅ Delegation — one listener, attached once, handles all current and future children:
```javascript
ul.addEventListener("click", (e) => {
  const li = e.target.closest(".item");
  if (!li) return;

  handleItem(li);
});
```

Attach listeners once. Never place `addEventListener` in a function that can be called more than once — listeners accumulate (there is no `replaceEventListener`). Separate one-time initialization (DOM refs, listeners) from repeatable actions (reset state, re-render). `init` may call `reset`; `reset` must never call `init`.

Do not speculatively cache DOM references the code may never use. `getElementById` is a hash-table lookup — fast enough to call at point of use. Speculative caching adds a sync burden (HTML changes require updating the cache) and initialization cost for elements the user may never interact with.

### Active Object

For exclusive-active state (tabs, selections, panels): hold a reference to the currently active element. On switch, deactivate it directly, then activate the new one. Never `querySelectorAll` to scan siblings and remove a class. This is the same principle as [Minimize Traversal Scope](#minimize-traversal-scope): do not scan a set when you already have the element you need.

### Shared Key

#### Governing Statement

Use one string _key_ across associated lookups in data, DOM, and behavior.

#### Rule

When code associates an object property and a DOM element, give them a shared meaningful key, typically `id`. The same string key can address data (`data[id]`), get an element (`document.getElementById(id)`), and route actions (`CLICK_DISPATCH[id]`). One key supports multiple direct lookups and [minimizes traversal](#minimize-traversal-scope).

#### Terms

- **Shared Key** - the Web XP Pattern.
- **key** - unique semantic key that names the entity or relationship.
- **key slot** - the element-owned property or data-owned place where the key belongs.
- **direct access** - addressing data, DOM, dispatch, relationship maps, or behavior by key instead of scanning.

#### Module Ownership

A module owns the keys for the domain concept it implements. The DOM (including events), data, and behavior intermix at the module; Shared Key bridges them while each layer keeps its internals encapsulated.

Other modules consume those keys; they do not define them. Module-owned prefixes — or caller-provided IDs for widgets with multiple instances (`salon-calendar`, `deliveries-calendar`) — keep keys unique. Two elements with the same ID is a bug.

#### Legitimate Iteration

Iteration is justified for rendering, ordering, filtering, or transforming collections, not to recover one already-known entity by key.

#### Known Key

For objects with unique identifiers (SKU, CUSIP, VIN, or any other UID), use the identifier as the key.

In JSON, object property names should serve as unique keys when keyed lookup is wanted.

Use `{ [key]: object }`, not `[ { id: key, ... } ]`. Searching an array for a matching `id` is O(n), which defeats
Shared Key.

**Code Smell**

The code scans a list to recover an object whose identifier is already known.

```js
const question = QUESTIONS.find(question => question.id === questionId);
```

**Finding**

Lookup for a specific thing implemented as repeated search instead of direct access by string key.

**Trigger**

```text
.find(...) comparing an object identifier to a known identifier, or
querySelector('[data-id="..."]') / [attr="..."] selectors recovering an entity by a known key
```

**Resolution**

Do not repeat `.find(...)` if the data have identifiers. Get them as an object keyed by identifier (ask backend, if needed). If that cannot happen, such as with siloed backend/frontend ownership, transform the list once, ideally on demand.

**Preferred Shape**

```js
const question = QUESTIONS[questionId];
```

If you cannot change the data, convert it to a keyed object for repeated O(1) lookups:

```js
const QUESTIONS_BY_ID = Object.fromEntries(
  QUESTIONS.map((question) => [question.id, question])
);
```

**Investigation**

- Are you looking for a specific thing?
- What uniquely identifies it?
- How can that identifying criteria be represented as a string key?
- Can that key be carried instead of recovered by search?
- Can the data source provide an object keyed by that string?

#### Relationship Scan, Composite Key

**Code Smell**

The code knows the endpoint keys but scans a relationship list to find that relationship.

```js
const link = links.find((link) =>
  link.from === fromId && link.to === toId);
```

**Trigger**

```text
.find(...) comparing from/to endpoint keys
```

**Finding**

Lookup for a specific relationship is implemented as repeated search instead of direct access by string key.

**Resolution**

Use a composite key. If endpoint order should not matter, canonicalize it before lookup.

**Preferred Shape**

```js
const link = linksByPair[canonicalPairKey(fromId, toId)];
```

**Investigation**

- Are you looking for a specific relationship between two things?
- What uniquely identifies that relationship?
- Can that relationship be represented as a string key?
- Should endpoint order change the key?

#### Key Slots

Use elements and attributes that fit the context. Do not shoehorn keys into `id`. A button's `value` may carry a key more directly than an `id` suffix.

Use meaningful identifier tokens in element ids. For associated elements, use the same token with a suffix for each one's role so each id is unique, addressable, and identifiable to humans.

For JavaScript objects, the key slot is the object property key.

#### Element Key Slots

- `id` when the DOM element itself needs stable identity.
- `value` when a form-associated control carries the key for what it represents or acts on.
- `<data value>` when visible content has a machine-readable entity key.
- `name` when a form field contributes the payload key.
- `data-*` when no more specific key slot fits.

#### Forced Key

**Code Smell**

A key is fabricated to fit a slot, or stored in a slot whose semantics don't match the element's role.

```html
<button type="button" id="mq-result-save-q42">Save as Flashcard</button>
```

```js
saveCard(button.id.replace('mq-result-save-', ''));
```

**Trigger**

`.id.replace(` or templated id `` `<prefix>-${key}` `` paired with dispatch routing on the prefix.

**Investigation**

- Where does the key belong — `id`, `value`, `<data value>`, `name`, or `data-*`?
- What is the element's role (DOM identity, form control, label, data carrier, payload)?

**Finding**

Either or both:

- The key is stored in a slot that does not suit the element and the key.
- The key is contrived just to force `id` through the DOM.

**Resolution**

Choose the element and key slot (property or attribute) whose meaning suits the key. Do not force the key into the wrong place just to move it through the DOM.

```html
<button type="button" value="q42">Save as Flashcard</button>
```

```js
saveCard(button.value);
```

#### Misplaced Key

**Code Smell**

Collection is represented as an array of objects, each with its key as a property (such as id). Retrieval by that key requires an O(n) scan.

```
  "causalChains": [
    { "id": "diaphragm-to-adt", "title": "...", "steps": [...] },
    { "id": "outlet-to-padt", "title": "...", "steps": [...] }
  ]
```

**Trigger**

Source data shaped as `[{ id, ... }]`, often paired with `.find(item => item.id === key)` at consumer sites.

**Investigation**

- Is the collection accessed by key, by order, or both?
- Is the data shape under app control, or externally supplied?
- Does any consumer rely on iteration order, or only on keyed lookup?

**Finding**

The collection has app-owned keys but is shaped as an array, forcing O(n) scans for keyed access.

**Resolution**

Represent the collection as an object keyed by identifier; `{ [id]: ... }`, not `[ { id: ... } ]`.

**Preferred Shape**

```
  "causalChains": {
    "diaphragm-to-adt": { "title": "...", "steps": [...] },
    "outlet-to-padt":   { "title": "...", "steps": [...] }
  }
```

#### Array Position Instead of Key

**Code Smell**

DOM ids derived from array position.

```js
chainState[ci]
el.id = `chain-${ci}`;
```

*HTML*

```html
<ul id="chain-2"></ul>
```

**Trigger**

`state[index]` paired with DOM IDs using the same index.

**Investigation**

- Is the element `id` derived from array position?
- What's the data access pattern? If the answer is "by position" or "in order", array is right and id is not needed.

**Finding**

The app key is present in the data, but state and DOM are addressed by array index instead.

**Explanation**

`ci` is array position; `id` is the app key, already in the data. The problem was using a positional stand-in for identity when the app key existed. The fix was to use the app key as the single identity across data, state, and DOM. The solution also added a Decorator with an `id` getter inside a Decorator Factory.

**Resolution**

Use the app key as the single identity. Use array position only for order.

**Preferred Shape**

```js
chainState[chain.id]
el.id = chain.id;
```

*HTML*

```html
<ul id="causal-chain-respiration"></ul>
```

**Boundary**

If the data are still `[ { id, ... } ]`, this may also be Misplaced Key.

#### Related Rules / Related Sections

- **Minimize Traversal Scope** - when the key is known, address the target directly.
- **Event Delegation** - delegated events often provide the element whose key slot resolves the key.
- **Ubiquitous Language** - keys use app/domain language, not generated or positional handles.
- **Dispatch Table** - action routing can use the same key for direct dispatch.
- **Decorator** / **Decorator Factory** - consumes Shared Key when creating or retrieving one behavior object per keyed Element/UI object.
- **Active Object** - may hold the currently active keyed element or object directly.
- **Encapsulation** - limits what crosses the Shared Key contract.

### Ancestor Class for Batch Styles

To style a group of descendants, add a class to the nearest common ancestor. Define the CSS rule as `.state-class .descendant-class`. Never loop through descendants to set `element.style`.

❌ Toggling visibility on each element:
```javascript
quizWrap.classList.add("hidden");
scoreEl.classList.add("hidden");
resultsEl.classList.remove("hidden");
```

✅ One class on the ancestor, CSS cascade w/nested rule does the rest:
```javascript
section.classList.add("showing-results");
```
```css
#section.showing-results {
  #quiz-wrap, #score { display: none; }
  #results { display: block; }
}
```

### Inline Styles in Scripts

Avoid inline styles — use CSS classes. When dynamic inline styles cannot be avoided (e.g. computed positions), assign multiple values via `element.style.cssText` rather than setting individual `style` properties one at a time.

### CSS over JS for State Presentation

Use CSS for visual state changes wherever possible. Prefer `:hover`, `:focus`, `:not(.class)`, and `pointer-events` over JS event handlers (`mouseenter`/`mouseleave`) and programmatic `disabled` toggling. If CSS can express the rule, JS should not be involved.

### `hidden` Attribute for Visibility

Use the native `hidden` attribute for show/hide toggling instead of `style.display`. It is semantic, works without knowing the element's display type, and is removable with `el.hidden = false`.

### Extract Shared Logic

When two or more code blocks follow the same structure but differ in specific values or operations, extract the shared structure into a function parameterized by the varying parts. Pass data for values that differ; pass a function for operations that differ. This applies to DOM construction, string building, iteration — any structural duplication. The extracted function encapsulates *structure*; the caller supplies *what varies*.

### Dispatch Table

When a chain of conditionals maps a value to an action, replace it with a keyed object. The table makes the mapping visible at a glance, is trivial to extend, and separates routing from logic.

❌ Conditional chain:
```javascript
if (id === "submit") handleSubmit();
else if (id === "new-session") resetSession();
else if (id === "end-session") renderResults();
else if (id === "retake-missed") retakeMissed();
```

✅ Dispatch table — pairs naturally with event delegation:
```javascript
const CLICK_DISPATCH = {
  "equiv-submit": handleSubmit,
  "equiv-new-session": resetSession,
  "equiv-end-session": renderResults,
  "equiv-retake-missed": retakeMissed
};

section.addEventListener("click", (e) => {
  const target = e.target.closest("[id]");
  CLICK_DISPATCH[target?.id]?.();
});
```

### Functions

Functions must do one thing. The name must clearly reflect what that thing is. Consistent return type — callers should not need to check which shape came back. Pure where possible. Three or fewer parameters; use an options object when more context is needed. Within a function, each step operates at the same level of abstraction — the body reads as a table of contents for the operation. When a chain of conditionals routes to different actions, consider a dispatch table or function redefinition.

Inline callbacks follow the same rule. The listener is routing; the function is logic.

❌ Logic buried in callback:
```javascript
el.addEventListener("click", (e) => {
  const target = e.target.closest(".item");
  if (!target) return;
  // ... 30 lines of processing ...
});
```

✅ Callback delegates to named function:
```javascript
el.addEventListener("click", (e) => {
  const target = e.target.closest(".item");
  if (!target) return;

  processItem(target);
});
```

### Decompose Conditional

When a boolean expression is complex, extract it into a named variable or function that reads as intent. The name replaces the logic, making the condition's purpose obvious at the call site.

### Template and cloneNode

When creating multiple similar elements in a loop, build one template element outside the loop with shared attributes and classes, then `cloneNode(false)` inside the loop and set only the per-instance values. Avoids redundant `createElement` / `setAttribute` / `classList.add` calls per iteration. Per-instance assignment should follow [Prefer properties over `setAttribute`](#javascript-1) — set typed properties directly and batch with `Object.assign`, falling back to `setAttribute` only for SVG / custom / unreflected ARIA attributes.

---

## Formatting

### General

- Line length: target 80 columns, 90 maximum. Do not break a line that fits within the target. When a line must break, break at the [highest syntactic level](https://google.github.io/styleguide/jsguide.html#formatting-where-to-break) — after an operator, after a comma, or before a chained method. Continuation lines indent +4.

### HTML

- Lowercase tags, quoted attributes.
- No self-closing slash where end tag is forbidden (`<img>` not `<img />`).

### CSS

- External stylesheets only. No inline `<style>` blocks.
- One declaration per line, opening brace on selector line, one blank line between rules.
- Space after the colon in property declarations: `margin: 0` not `margin:0`.
- In CSS functions like `rgb()`, include a single space after each comma.

### JavaScript

- Semicolons explicit. Do not rely on ASI. Restricted productions (`return`, `throw`, `break`, `continue`, postfix `++`/`--`): the expression must start on the same line as the keyword. Do not add a semicolon after a function declaration, block, switch, or try/catch — a semicolon there is an empty statement.
- Use template literals for large multi-line HTML/SVG builders. Use concatenation for short one-liners.

---

## Language Rules

Semantic and behavioral rules. Where these overlap with the baseline authorities, this document governs.

### HTML

- Valid markup. Code that uses malformed HTML is expecting nonstandard behavior. When a browser encounters an HTML error it performs proprietary error correction, producing a DOM that differs from what the code expects.
- Semantic elements: headings, nav, section, article — not generic divs. Nav lists, not buttons. ARIA roles where semantics fall short.
- No inline styles except those set dynamically by JS at runtime.
- No `javascript:` pseudo-protocol.
- No inline event handler attributes (`onclick`, `onchange`, etc.).

### CSS

- Separate structure from domain styles (e.g., `layout.css` for shared primitives; `css/<domain>.css` for each module).
- Class and id selectors must have semantic meaning. `.redButton` is meaningless; `.errorAction` represents a state. See: [Use class with semantics in mind](https://www.w3.org/QA/Tips/goodclassnames). Use unambiguous names from the project's ubiquitous language: `activeTab`, `activeSubtab` — not `.active`.
- Modular CSS: each file groups conceptually-related functionality, does one thing, and minimizes dependence on other CSS files.
- All colors via CSS custom properties. Never hardcode hex or rgb in rules. Define custom properties on `:root` in the CSS file that owns the concept. If a dark mode override is needed, define it in `@media (prefers-color-scheme: dark)` in the same file.
- System font stacks by default. No CDN fonts unless the project spec requires a brand typeface — and if it does, self-host; do not load from third-party CDNs at runtime. Scalable font sizes using `clamp()` — define a font scale as custom properties on `:root` and use those for all `font-size` declarations. No fixed `px` or bare `rem` font sizes in rules.
- Mobile-first. Base styles target small screens; widen with `min-width` media queries. Images: `max-width: 100%; height: auto`. Overlay positioning uses percentages. No layout element should require horizontal scrolling at the project's minimum target viewport width (typically 320px).
- Light/dark theme via `prefers-color-scheme`. Unless otherwise stated by the user, provide both. Define the primary palette on `:root`, the alternate in the media query. No manual toggle unless the project spec requires one.
- **Unit conventions.** `px` for borders — sub-pixel borders render poorly in fractional units. `rem` for padding, margin, gap, border-radius, and box-shadow — these scale with the root font-size and stay proportional to the containers they belong to. `clamp()` custom properties for font sizes (already stated above). Do not mix: a `rem`-padded, `rem`-radiused card with a `px` shadow is a unit mismatch that scales unevenly.
- **Transition consolidation.** When multiple properties in a `transition` declaration share the same duration and timing function, use `all` instead of enumerating each property. Listing three properties with identical timings restates the same value three times.

  ❌ Same duration repeated per property:
  ```css
  transition: border-color var(--dur-fast),
    background var(--dur-fast),
    color var(--dur-fast);
  ```

  ✅ Consolidated:
  ```css
  transition: all var(--dur-fast);
  ```

  Use individual properties only when they need *different* durations or timing functions.
- **Defensive selectors.** Do not use positional pseudo-classes (`:last-child`, `:first-of-type`, `:nth-last-child`) on containers where JavaScript adds or removes children. The selector breaks silently when the child count changes. Pin to a known structural position with `:nth-child(n)`, or use a class.

  ❌ Breaks when JS appends a sibling:
  ```css
  .card > span:last-child { color: var(--text-dim); }
  ```

  ✅ Stable regardless of dynamic children:
  ```css
  .card > span:nth-child(2) { color: var(--text-dim); }
  ```

### JavaScript

- **Modules.** `<script type="module">` — strict mode by default. ES modules with explicit exports. Do not wrap an entire module body in an IIFE — the module already provides scope. IIFEs remain useful for creating closures within a module (e.g. binding private state to a function).
- **Functions.** Use function declarations for named module-level functions (hoisted, readable top-down). Use arrow functions instead of anonymous function expressions when `this` doesn't matter or is wanted from the enclosing context. Use function expressions when the handler needs `this` bound to the element by `addEventListener`.
- **Variables.** Declare with `const` or `let`, close to first use. Minimize the visibility of the identifier, but maximize the stability of the implementation — keep the variable narrow, but keep the function it references in a stable scope so you aren't punishing the engine. No assignment to undeclared identifiers.
- **Function allocation.** Any anonymous function inside a repeated code path (loop, handler, render, timer) that doesn't close over per-execution state is a redundant allocation. Define functions once at a stable scope; reference them from the hot path.

  | Approach | Readability | Performance | Use when |
  |---|---|---|---|
  | Inline anonymous | High (logic in place) | Low (constant re-creation) | One-shot code paths only |
  | Hoisted named | Medium (jump to def) | High (single allocation) | Loops, renders, handlers |
  | Event delegation | Medium (abstracted) | Highest (minimal footprint) | Large/dynamic DOM trees |

  How to spot the anti-pattern: any anonymous function defined inside a function that runs more than once. If you can move it outside and nothing breaks, it should be outside.

  ❌ Function recreated on every click:
  ```javascript
  revealBtn.addEventListener("click", () => {
    const html = parts.map(
      ([k, v]) => "<strong>" + k + ":</strong> " + v
    ).join("<br>");
  });
  ```

  ✅ Formatter defined once, referenced by name:
  ```javascript
  function formatKeyValue([k, v]) {
    return "<strong>" + k + ":</strong> " + v;
  }

  revealBtn.addEventListener("click", () => {
    const html = parts.map(formatKeyValue)
      .join("<br>");
  });
  ```
- **Naming conventions.** Constants: `UPPER_SNAKE_CASE`. Functions/variables: `camelCase`. Classes: `PascalCase`. Booleans prefixed: `is`/`has`/`does`/`can`. Event handler functions: `[object][EventName]Handler` (e.g. `itemClickHandler`, `formSubmitHandler`). Functions that process results but do not receive an event object are not handlers — name them by what they do (e.g. `validateInput`, `saveRecord`). Give each identifier a meaningful name from the project's ubiquitous language.
- **Identifier naming.** Materially accurate. Names describe the domain reality, not the programming artifact. No generic state words (`active`, `hidden`, `val`, `data`, `item`). No abbreviations (`cmap`, `mq`, `expl`) — use full terms (`conceptMap`, `masterQuiz`, `explanation`). State variables within a module should mirror the module's DOM prefix to maintain a single address space.

  ❌ Generic or abbreviated:
  ```javascript
  const MAP = {};
  const active = null;
  const val = getRotation();
  ```

  ✅ Materially accurate:
  ```javascript
  const ABBR_TITLES = {};
  const activeDragItem = null;
  const pelvisRotationDegrees = getRotation();
  ```
- **Guard clauses.** Use early `return` to reject invalid state at the top of a function rather than wrapping the body in a conditional. Always follow a guard clause with a blank line so the pattern stands out visually.
  ```javascript
  function update(id) {
    if (!id) return;

    // function body
  }
  ```
- **DOM content.** `textContent` over `innerHTML`. Use `innerHTML` only when inserting HTML structure.
- **Form submission.** No form submission on Enter unless that is the intended UX. Prevent default on `keydown` where needed.
- **Strict equality.** `===` always. Do not use Boolean coercion on values that may be acceptably falsy (e.g., `if (e.pageX)`). Use `typeof`: `if (typeof e.pageX === 'number')`.
- **String concatenation.** Do not `+=` in a loop — each iteration creates and discards an intermediate string. Use `.join()` for uniform items; use `.map()` + `.join('')` when each item needs distinct attributes.

  ❌ `+=` in a loop creates n intermediate strings:
  ```javascript
  let html = "<ul>";
  items.forEach((item) => { html += "<li>" + item + "</li>"; });
  html += "</ul>";
  ```

  ✅ Uniform items — join with delimiter (guard empty case):
  ```javascript
  if (items.length) {
    el.innerHTML = "<ul><li>" + items.join("</li><li>") + "</li></ul>";
  }
  ```

  ✅ Per-item attributes — map + join:
  ```javascript
  el.innerHTML = items.map((item) =>
    "<div data-id=\"" + item.id + "\">" + item.name + "</div>"
  ).join("");
  ```
- **Regular expressions.** Prefer simple patterns. Anchor where needed to avoid false matches. Test success and failure cases.
- **Prefer properties over `setAttribute`.** Set DOM state through properties, not `setAttribute`. Properties take typed values directly — `disabled = true` instead of `setAttribute("disabled", "")`, `tabIndex = -1` instead of `setAttribute("tabindex", "-1")`. `setAttribute` is the fallback only when no property exists: custom attributes, most SVG attributes, and ARIA attributes whose property form is not in the supported browser baseline. For `data-*` set with a static name, use `dataset`; use `setAttribute` only when the data name is computed.

  For multiple values on the same element, use `Object.assign`.

  ❌ `setAttribute` per-property:
  ```javascript
  el.setAttribute("id", "save");
  el.setAttribute("class", "btn primary");
  el.setAttribute("disabled", "");
  el.textContent = "Save";
  el.setAttribute("data-action", "save");
  ```

  ✅ Properties + `Object.assign` + `dataset`:
  ```javascript
  Object.assign(el, {
    id: "save",
    className: "btn primary",
    textContent: "Save",
    disabled: true,
  });
  el.dataset.action = "save";
  ```

  When `setAttribute` is the right tool (SVG attributes, custom attributes) and multiple values are going on the same element, batch them via `Object.entries` instead of repeating the call:

  ❌ Repeated `setAttribute`:
  ```javascript
  markerEl.setAttribute("id", markerId);
  markerEl.setAttribute("markerWidth", "8");
  markerEl.setAttribute("markerHeight", "6");
  markerEl.setAttribute("refX", "8");
  markerEl.setAttribute("refY", "3");
  markerEl.setAttribute("orient", "auto");
  ```

  ✅ Property where it exists, `Object.entries` for the rest:
  ```javascript
  markerEl.id = markerId;
  Object.entries({
    markerWidth: "8",
    markerHeight: "6",
    refX: "8",
    refY: "3",
    orient: "auto",
  }).forEach(([k, v]) => markerEl.setAttribute(k, v));
  ```

  This rule pairs with [Template and cloneNode](#template-and-clonenode): the per-instance assignment site after `cloneNode(false)` is exactly where the property-vs-`setAttribute` choice matters most.

---

## Comments

Comments are a failure of the code to express itself. When one is necessary, it should justify its existence.

- Comments explain *why*, not *what*. If the comment restates the code, delete it.
- Avoid comments likely to become obsolete. A comment that drifts from the code it describes is worse than no comment.
- No decorative banner or landmark comments (`═══`, `───`, `****`, `/* ── Section ── */`). Use code structure — function names, module boundaries, blank lines — to communicate organization.
- Avoid file header comments, except for necessary information that cannot be placed more locally.
- A comment *is* warranted when code intentionally violates a project convention. State the violation, why it exists, and how it is handled instead. Without this, a future reader will "fix" the code back to the convention and break the design.
- A comment *is* warranted in a `catch` block that intentionally suppresses an error. State what operation failed, why the failure is acceptable, and what the user loses. An empty `catch` body without a comment is indistinguishable from a bug.
- Remove dead comments. Commented-out code, obsolete TODOs, and notes that no longer apply are clutter. They mislead readers and accumulate. If the code is gone, the comment goes with it. Version control preserves history — the comment does not need to.

---

## Version Control

- Atomic commits: one logical, cohesive change per commit. A commit should do one thing and do it completely — all files affected by that change, nothing unrelated.
