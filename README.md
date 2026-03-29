# Web XP

### AI-Assisted XP for Lean, Transparent Web Front-End

Governing rules, named refactoring patterns, and review skills for building applications directly on the web platform. The code stays legible, stable, and maintainable as it grows.

Web XP takes the XP habits of tight feedback, simple design, and continuous refactoring and turns the dials up with AI-assisted review. The goal is not more generated code for its own sake. The goal is better code, produced faster, under active human judgment.

Kent Beck once asked, "What if we took all the good practices and turned the dials up to 11?" Web XP takes that instinct seriously on the web platform: AI tightens the feedback, review, and refactoring loops rather than replacing engineering judgment.

## Why It Exists

AI writes code fast. Without constraints, it writes inconsistency and maintenance debt just as fast.

Web XP exists to keep speed from dissolving into slop. It defines governing rules, reusable patterns, and review skills for applications built directly on the web platform, with an emphasis on code that remains clear, debuggable, and durable over time.

The point is not to recreate framework dependency in lighter clothing. Many framework abstractions solve problems introduced by the framework itself. Web XP keeps more of the system legible by working with the DOM and standardized Web APIs directly.

## What You Get

- **Governing standards** in `code-guidelines.md`: principles, named patterns, language rules, and formatting defaults.
- **Explanatory context** in `code-philosophy.md`: why the standards work, how framework-era assumptions weakened, and what replaces common abstractions.
- **Review and refactoring skills** for Claude Code: load the standards, audit a diff, review arbitrary code, or walk through fixes interactively.
- **Mechanical checks** in `bin/pre-commit-check.sh` for recurring violations such as inline handlers, hardcoded colors, loose equality, and junk-drawer filenames.

## What It Covers

Web XP is not just style guidance. Its concrete examples live in `code-philosophy.md`, especially around:

- routing and URL-driven navigation
- state management and scope
- explicit initialization and data fetching
- failure handling and graceful degradation
- DOM ownership, dispatch, and CSS-driven state

If you want the argument and examples first, start with `code-philosophy.md`. If you want the operational rules and named patterns first, start with `code-guidelines.md`.

## Claude Code Skills

First-time setup:

```bash
git clone https://github.com/GarrettS/code-guidelines.git ~/.claude/web-xp
mkdir -p ~/.claude/skills
cp -r ~/.claude/web-xp/.claude/skills/* ~/.claude/skills/
```

To update later:

```bash
cd ~/.claude/web-xp && git pull
cp -r .claude/skills/* ~/.claude/skills/
```

Available commands are listed under [Explicit Mode](#explicit-mode) and [Always-On Mode](#always-on-mode) below.

## Git Submodule

If you just want to use Web XP in Claude Code, the skill path above is simpler. Use the submodule path when you want the standards files present inside your own repository for direct references, pinned revisions, or project-specific standards work:

```bash
git submodule add https://github.com/GarrettS/code-guidelines.git .web-xp
```

The standards files and skills live in `.web-xp/`. The hosting project records a specific standards commit.

A submodule gives your project a local snapshot of the standards, and snapshots drift. To avoid version drift, add a note to your project's `project.md` telling Claude to check whether `.web-xp` is behind the canonical `code-guidelines` repository before major work, at periodic commits, and when pulling upstream standards changes.

Note: `bin/check-web-xp-sync.sh` is internal to the Web XP repo — it auto-copies root standards files into `.claude/skills/` with DO NOT EDIT headers. Submodule consumers do not need it; the submodule pointer itself pins your standards version.

To update a consuming project:

```bash
cd .web-xp
git pull origin main
cd ..
git add .web-xp
git commit -m "Update Web XP standards"
```

If you want the project-local rule set first:

- read `.web-xp/code-guidelines.md` for the governing rules and named patterns
- read `.web-xp/code-philosophy.md` for the examples and explanatory context
- use `/web-xp-check` and `/web-xp-apply` inside the project workflow

## Explicit Mode

On-demand slash commands for specific tasks.

| Command | Purpose |
|---------|---------|
| `/web-xp` | Load the governing rules into the current session |
| `/web-xp-init` | Set up a new project with CLAUDE.md and pre-commit script |
| `/web-xp-check` | Read-only audit of the current diff |
| `/web-xp-apply` | Walk through findings one at a time with approval |
| `/web-xp-review` | Review any code against the standards |

## Always-On Mode

Web XP stays loaded and context-aware. Before writing or reviewing any JS, HTML, or CSS, Claude Code loads the standards and checks against them before every commit — automatically, no prompting required. This is driven by directives in your project's `CLAUDE.md`, generated by `/web-xp-init`.

| Command | Purpose |
|---------|---------|
| `/web-xp-on` | Enable always-on Web XP enforcement |
| `/web-xp-off` | Disable always-on Web XP enforcement |

## Workflow Strategy

For AI-assisted development under active human review. The standards constrain AI output and provide a shared vocabulary for correction and refactoring. They are most effective in the hands of an experienced developer who can recognize when the AI is structurally right, mechanically wrong, or conceptually off-base.

Each rule traces back to a specific failure observed during development. When the AI produces an anti-pattern, do not just fix the code. Tighten the rule so the failure is easier to catch the next time.

### Why the Pre-Commit Sequence Matters

> "The main thing that helps me see propagation is being told to look. The CLAUDE.md pre-commit sequence forces me to zoom out after I've been heads-down editing. Without that step, I'd mark the task done after the last edit." — Claude

### Avoiding Repetitive Approval Fatigue

By default, Claude will present the same mechanical edit (renaming a class, removing an attribute, changing a prefix) one location at a time — each requiring separate approval. Ten occurrences means ten approvals for the same change. This is tedious and encourages auto-approve, which defeats the review loop.

Add this to your project's `CLAUDE.md` to fix it:

```
- **Batch cohesive mechanical changes.** When a refactoring requires the
  same transformation applied to multiple locations (renaming an ID,
  replacing a class, removing an attribute), apply all instances in a
  single `replace_all` edit or a single block edit — not one at a time.
```

## Canonical Workflow

This repository is the canonical source for Web XP.

When changing Web XP itself:

1. Edit and commit in a working clone of `code-guidelines`.
2. Push the change to the canonical GitHub repository.
3. Update any consuming project that vendors the standards as a submodule.
4. Commit the submodule pointer update in that parent project separately.

Changing the standards and updating a consuming project to use that change are separate repository changes.

## Disabling

Web XP enforcement is driven by your project's `CLAUDE.md`. To disable it for a project, run `/web-xp-off` (or manually comment out the Web XP directives). To re-enable, run `/web-xp-on`. To disable globally, remove the skills from `~/.claude/skills/`.

## License

MIT
