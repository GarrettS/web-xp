# Web XP — Load Session Constraints

Read `code-guidelines.md` and `code-philosophy.md` from your Web XP install. Apply the following as constraints for all code written or reviewed in this session.

## Design Principles

- **Fail-Safe** — every failure resolves to a defined safe outcome. No unhandled exceptions, no silent failure paths.
- **Ubiquitous Language** — variables, class names, CSS selectors, function names use domain terms, not programmer shorthand.
- **Module Cohesion** — each module owns one domain concept. No junk-drawer names (`utils.js`, `helpers.js`).
- **Minimize Traversal Scope** — address elements directly when the reference is known. Do not scan broader than necessary.
- **DOM-Light** — favor source HTML over JS-generated markup. Use native elements first.
- **Design Tokens** — repeated CSS values are custom properties on `:root`, named by role.

## Patterns

Event Delegation, Active Object, Shared Key, Ancestor Class, Dispatch Table, CSS over JS, `hidden` attribute, Extract Shared Logic, Template and cloneNode, Decompose Conditional.

For full pattern definitions, read `code-guidelines.md` from your Web XP install. For reasoning and examples, read `code-philosophy.md`.

## For this session

- Evaluate all code written or reviewed against these constraints
- Flag violations by pattern name
- When proposing code, follow the patterns
- Use `code-philosophy.md` to explain reasoning, not to invent rules
- When the standards conflict with a request, state the tension and ask
- On commit, remind to run pre-commit checks
