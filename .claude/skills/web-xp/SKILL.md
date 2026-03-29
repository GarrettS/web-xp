---
name: web-xp
description: "Load code-guidelines.md and code-philosophy.md as session constraints. Activate when: coding task begins, 'web-xp', 'web xp', 'code guidelines', 'standards', writing or reviewing JS/HTML/CSS."
---

# Web XP — Session Constraints

These constraints govern all code written or reviewed for the remainder of this conversation. The summary below is the working reference. For full pattern details, examples, and edge cases, read `${CLAUDE_SKILL_DIR}/../code-guidelines.md`. For the reasoning behind the rules, read `${CLAUDE_SKILL_DIR}/../code-philosophy.md`.

---

## Design Principles

### Fail-Safe

No unhandled exceptions and no silent failure paths. Every failure resolves to a defined safe outcome.

- **User-initiated operations** (Save, submit, fetch) — failure must be user-visible: a message, retry option, fallback, or graceful degradation.
- **Background enhancements** (auto-save, prefetch, analytics) — silent degradation is correct. Comment the catch stating what degrades and why.
- Three violations: unhandled throw, silent return (`null`/`undefined`), console-only catch.
- Guard `fetch()` (network + HTTP status), `JSON.parse()`, `localStorage` (throws in private mode), fire-and-forget async (`.catch()` at call site).

### Ubiquitous Language

Variables, class names, CSS selectors, function names, DOM IDs, JSON keys, and docs use domain terms. If the user says "concept map," the code says `conceptMap` — not `cmap`, `graph`, or `diagram`. Domain abbreviations are fine; programmer shorthand is not.

### Module Cohesion

Each module owns one domain concept. Name it after what it does: `quiz.js`, `navigation.js`. Junk-drawer names (`utils.js`, `helpers.js`, `common.js`) are violations.

### Minimize Traversal Scope

When the element, ancestor, or key is known, address it directly. Do not scan a broader scope than necessary. Active Object, Event Delegation, and Shared Key are specific applications of this principle.

### DOM-Light

Favor source HTML over JS-generated markup. Use native elements (`<form>`, `<details>`, `<button type="button">`) before JS equivalents.

### Design Tokens

Repeated CSS values are named once as custom properties on `:root`. Name by role, not value (`--dur-fast`, not `--duration-120`). Dark mode is a token concern — define both palettes in the same file, components consume tokens only.

---

## Patterns

### Event Delegation
One handler on a stable ancestor, inspect `event.target`. Use `closest()` when nested markup can receive the event. Never place `addEventListener` in a function called more than once — listeners accumulate.

### Active Object
Hold a reference to the currently active element. On switch, deactivate it directly, activate the new one. Never `querySelectorAll` to scan siblings.

### Shared Key
One `id` string indexes data (object property), DOM (`getElementById`), and dispatch (action route). Structure JSON as keyed objects, not arrays. Module-owned prefixes prevent collisions. Antipattern: `.find(item => item.id === id)`, `querySelector('[data-id="..."]')`.

### Ancestor Class
Style a group of descendants by adding one class to their common ancestor. CSS cascade does the rest. Never loop through descendants toggling classes.

### Dispatch Table
Replace conditional chains mapping values to actions with a keyed object. Pairs naturally with event delegation.

### CSS over JS
Use CSS for visual state (`:hover`, `:focus`, `:not()`, `pointer-events`) instead of JS handlers when CSS can express the rule.

### `hidden` Attribute
Use `el.hidden` for show/hide, not `style.display`.

### Extract Shared Logic
When two+ blocks follow the same structure with different values, extract a parameterized function.

### Template and cloneNode
Build one template element outside a loop, `cloneNode()` inside, set per-instance values only.

### Decompose Conditional
Extract complex boolean expressions into named variables or functions that read as intent.

---

## Language Rules (Key Points)

### HTML
Valid markup. Semantic elements. No inline styles (except JS-set at runtime). No `javascript:` pseudo-protocol. No inline event handlers.

### CSS
- All colors via custom properties. No hardcoded hex/rgb in rules.
- System font stacks default. `clamp()` custom properties for font sizes.
- Mobile-first. `min-width` media queries.
- Light/dark via `prefers-color-scheme` — provide both unless spec says otherwise.
- Units: `px` for borders, `rem` for padding/margin/gap/radius/shadow, `clamp()` for font sizes.
- External stylesheets only. No inline `<style>` blocks.
- Semantic selectors from domain language.
- Transition consolidation: use `all` when duration/timing are identical.
- Defensive selectors: no `:last-child` on dynamic containers.

### JavaScript
- ES modules (`<script type="module">`). No IIFE wrappers.
- Function declarations for module-level. Arrow functions when `this` doesn't matter.
- `const`/`let`, close to first use. No undeclared assignments.
- No anonymous functions in repeated code paths unless they close over per-execution state.
- Naming: `UPPER_SNAKE` constants, `camelCase` variables/functions, `PascalCase` classes. Boolean prefix: `is`/`has`/`does`/`can`. Handlers: `[object][Event]Handler`.
- Materially accurate identifiers. No generic words (`data`, `item`, `val`). No abbreviations (`cmap`, `mq`).
- Guard clauses with blank line after.
- `textContent` over `innerHTML` unless inserting HTML structure.
- `===` always. No boolean coercion on acceptably-falsy values.
- No `+=` in loops — use `.join()` or `.map().join('')`.
- Semicolons explicit.

### Comments
Explain *why*, not *what*. No decorative banners. Comment convention overrides and empty catches. Remove dead comments.

### Formatting
Line length: target 80, max 90. No self-closing slash on void elements.

---

## Applying Web XP

For the remainder of this conversation:
- Evaluate all code written or reviewed against these constraints
- Flag violations by pattern name
- When proposing code, follow the patterns
- Use `code-philosophy.md` to explain reasoning, not to invent rules
- When the standards conflict with a request, state the tension and ask
- On commit, remind to run pre-commit checks
