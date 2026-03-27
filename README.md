# Code Guidelines

Canonical vanilla-JS RIA doctrine for AI tools and human programmers. No frameworks, no build tools. Maximum readability and performance.
## What's Here

- **`code-guidelines.md`** — Operational rules, patterns, defaults, and constraints. What the code must look like.
- **`code-philosophy.md`** — Rationale, tradeoffs, and reasoning framework. Why the doctrine exists and how to think under it.

## How to Use

Add this repo as a git submodule:

    git submodule add https://github.com/GarrettS/code-guidelines.git .doctrine

The authoritative doctrine lives only in `.doctrine/`. Do not copy the files into the project root — a second editable copy drifts. The parent repo records which doctrine commit it is pinned to via the submodule ref. Any standalone clone of this repo (e.g. for reading or contributing) pulls from the same remote.

Reference the doctrine from your project's workflow contract (e.g. `CLAUDE.md`):

    - **`.doctrine/code-guidelines.md`** — governing standards
    - **`.doctrine/code-philosophy.md`** — explanatory context

Project-specific decisions — directory structure, asset strategy, content authority, breakpoints, theming — belong in a **project overlay** file (e.g. `project.md`, `CLAUDE.md`, or a PRD), not in a fork of the doctrine. When an overlay overrides a doctrine default, it must state which rule is overridden and why.

## Workflow Strategy

These guidelines are designed for AI-assisted development where a human drives and the AI proposes. The workflow resembles XP-style pairing — the human reviews and edits every line the AI produces. The guidelines constrain the AI's output and give the human a shared vocabulary for directing corrections. Keep auto-approve off — every file edit, shell command, and commit should require explicit approval. Auto-approve defeats the review loop that makes the pairing work.

Hone the guidelines iteratively. When the AI produces an anti-pattern — a silent failure, a magic number, a speculative DOM cache — do not just correct the code. Tighten the rule so the pattern does not recur. Each rule in the doctrine traces back to a specific failure observed during development.

## Authoring and Sync

Edit doctrine files in the project's `.doctrine/` submodule working tree. Commit and push from that submodule to publish changes to the canonical code-guidelines repository.

Other clones of the canonical repo, such as a standalone checkout in `~/Documents/code-guidelines/`, are just additional working copies of the same remote. Pull there to receive updates.

When a project uses the doctrine as a submodule, the parent repository pins a specific doctrine commit. After updating the submodule, run `git add .doctrine` in the parent repo to record the new pinned commit.

## Upstream / Downstream

- **Generalized improvements** to principles, patterns, or rules should be upstreamed back to this repo so all projects benefit.
- **Project-specific exceptions** stay in the project's overlay files. Do not pollute the doctrine with rules that only serve one codebase.

## Claude Code Skills

Five skills in `.claude/skills/`:

- **`/doctrine-init`** — Project setup. Copies doctrine files, creates pre-commit script and starter CLAUDE.md.
- **`/doctrine`** — Inline reference. Loads the CG as governing constraints for the current session. Uses CP for explanatory context, not as a second rules file.
- **`/doctrine-check`** — Read-only audit. Runs mechanical pre-commit checks, then reviews the current diff against doctrine patterns. Reports violations and opportunities without editing.
- **`/doctrine-apply`** — Interactive refactoring. Walks through doctrine-check findings one at a time, presenting each proposed change for approval before editing.
- **`/doctrine-review`** — Evaluate any code against the doctrine. Works on pasted snippets, file paths, or framework code. Shows vanilla equivalents side by side.

Projects with the `.doctrine` submodule get these automatically.

## Pre-commit Checks

`bin/pre-commit-check.sh` enforces mechanical doctrine checks: inline event handlers, hardcoded colors, junk-drawer filenames, loose equality, long lines, etc. It covers generalized checks only — project-specific checks (asset integrity, service worker manifests, PRD references) belong in the project's own script.
