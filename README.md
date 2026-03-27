# Web App Code Standards

Code standards, refactoring patterns, and review skills for JavaScript web app development in AI-assisted workflows. Vanilla JS. No frameworks or build tools required.

## Installation

```bash
git clone https://github.com/GarrettS/code-guidelines.git /tmp/code-guidelines
cp -r /tmp/code-guidelines/.claude/skills/* ~/.claude/skills/
```

Then in Claude Code:

```
/reload-plugins
```

## Skills

Five slash commands for auditing and refactoring:

| Skill | Description |
|-------|-------------|
| `/doctrine` | Load the standards as governing constraints for the current session |
| `/doctrine-init` | Project setup — creates starter CLAUDE.md and pre-commit script |
| `/doctrine-check` | Read-only audit of the current diff against all 10 patterns |
| `/doctrine-apply` | Interactive refactoring — walks through findings one at a time with approval |
| `/doctrine-review` | Evaluate any code (pasted snippets, file paths, framework code) against the standards |

## What's Included

Each skill has access to these bundled files:

- **`code-guidelines.md`** — Governing standards: principles, 10 named patterns, language rules, formatting.
- **`code-philosophy.md`** — Explanatory context: how and why the standards work, historical framing, and supporting examples.
- **`pre-commit-check.sh`** — Mechanical checks: inline event handlers, hardcoded colors, loose equality, long lines, etc.

## Patterns

The standards define 10 named patterns for recognition and enforcement:

1. **Event Delegation** — One listener on a stable ancestor, inspect `event.target`
2. **Active Object** — Hold a reference to the active element, switch directly
3. **Shared Key** — One ID indexes data, DOM, and dispatch
4. **Ancestor Class** — One class on a common ancestor, CSS cascade handles the rest
5. **Dispatch Table** — Keyed object replaces conditional chains
6. **Fail-Safe** — Every failure resolves to a user-visible outcome
7. **CSS over JS** — CSS for visual state changes where possible
8. **`hidden` attribute** — `el.hidden` for show/hide instead of `style.display`
9. **Extract Shared Logic** — Parameterized function over structural duplication
10. **Template and cloneNode** — Build one template outside the loop, clone inside

## Workflow Strategy

Designed for AI-assisted development where a human drives and the AI proposes. The human reviews every line the AI produces. The standards constrain AI output and give both sides a shared vocabulary for directing corrections.

Each rule traces back to a specific failure observed during development. When the AI produces an anti-pattern, tighten the rule so it doesn't recur.

## License

MIT
