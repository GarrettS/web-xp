# Web XP — Load Session Constraints

Adapter-neutral source for the `web-xp` capability.

## Purpose

Load the Web XP standard into the current session before writing or reviewing code.

## Activation

Activate when explicitly invoked by name. Auto-activate only if a Web XP project contract (`AGENTS.md`, `CLAUDE.md`, or `CODEX.md`) exists in the project.

## Adapter bindings

The concrete adapter wrapper must provide:

- the path to `code-guidelines.md`
- the path to `code-philosophy.md`
- any adapter-native activation wording or command name

## How to think when designing and writing code

- When naming: what role does this play?
- When entering async: cancel competing work first. Who owns this turn?
- When a completion fires: what is current state now?
- When proposing a pattern: does correct design prevent this problem?

These are not review checks. They are the lens you design through.

## Procedure

1. Read `code-guidelines.md`.
2. Read `code-philosophy.md`.
3. Apply the standard as constraints for the rest of the session.

## Working summary

### Design Principles

- **Fail-Safe** — every failure resolves to a defined safe outcome. No unhandled exceptions, no silent failure paths.
- **Ubiquitous Language** — variables, class names, CSS selectors, function names use domain terms, not programmer shorthand.
- **Module Cohesion** — each module owns one domain concept. No junk-drawer names (`utils.js`, `helpers.js`).
- **Minimize Traversal Scope** — address elements directly when the reference is known. Do not scan broader than necessary.
- **DOM-Light** — favor source HTML over JS-generated markup. Use native elements first.
- **Design Tokens** — repeated CSS values are custom properties on `:root`, named by role.

### Patterns

Event Delegation, Active Object, Shared Key, Ancestor Class, Dispatch Table, CSS over JS, `hidden` attribute, Extract Shared Logic, Template and cloneNode, Decompose Conditional.

For full pattern definitions, read `code-guidelines.md`. For reasoning and examples, read `code-philosophy.md`.

## Session behavior

- Evaluate all code written or reviewed against these constraints.
- Flag violations by pattern name.
- When proposing code, follow the patterns for the new code you write.
- Do not refactor existing code beyond the user's request just to make it conform to Web XP.
- If you notice pre-existing violations outside the requested scope, ask whether to fix them now, list them, or leave them.
- Use `code-philosophy.md` to explain reasoning, not to invent rules.
- When the standards conflict with a request, state the tension and ask.
- Before delivery or commit, run the adapter's Web XP pre-commit check command and follow the project contract's completion requirements.
- **Review Workflow Loop** — when `review-loop` is not `off` in the project overlay (`prd/project.md`) and `codex` is available, run it before presenting your work:
  1. `bash ~/.web-xp/tools/review-loop.sh HEAD <base>` — hand your uncommitted changes to Codex.
  2. Per finding: fix it if you agree (the user approves as usual); or dispute it / ask how it is triggered by writing to the review-responses file the loop names; or, if the answer depends on the use-case, describe how it could happen by accident, stop and ask the user, and record the decision in `prd/review-exclusions.md`.
  3. Re-run; repeat the per-finding handling until Codex returns none.
  4. Exit when Codex is clean and you are confident (present it), or when your confidence is not high enough (stop and ask the user).

  A Stop hook enforces this when installed. See `~/.web-xp/tools/review-loop.md`.
