# Code Guidelines

Canonical source for a generalized vanilla-JS rich internet application doctrine. No frameworks, no build tools, no abstraction for abstraction's sake.

## What's Here

- **`code-guidelines.md`** — Operational rules, patterns, defaults, and constraints. What the code must look like.
- **`code-philosophy.md`** — Rationale, tradeoffs, and reasoning framework. Why the doctrine exists and how to think under it.

## How to Use

Copy `code-guidelines.md` and `code-philosophy.md` into your project root. Keep them as checked-in files — they are living documents that the project's contributors (human and AI) read on every task.

Project-specific decisions — directory structure, asset strategy, content authority, breakpoints, theming — belong in a **project overlay** file (e.g. `project.md`, `CLAUDE.md`, or a PRD), not in a fork of the doctrine. When an overlay overrides a doctrine default, it must state which rule is overridden and why.

## Upstream / Downstream

- **Generalized improvements** to principles, patterns, or rules should be upstreamed back to this repo so all projects benefit.
- **Project-specific exceptions** stay in the project's overlay files. Do not pollute the doctrine with rules that only serve one codebase.

## Pre-commit Checks

Projects may adopt a repo-local pre-commit script to enforce mechanical doctrine checks (inline event handlers, hardcoded colors, junk-drawer filenames, loose equality, long lines, etc.). See the [PRI study tool](https://github.com/GarrettS/pelvis) `bin/pre-commit-check.sh` for an example. Strip it to generalized checks; leave asset-integrity and project-layout checks to the project overlay.
