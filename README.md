# Web XP

### AI-Assisted XP for Lean, Transparent Web Front-End

Governing rules, named refactoring patterns, and review skills for building applications directly on the web platform. The code stays legible, stable, and maintainable as it grows.

Web XP takes the XP habits of tight feedback, simple design, and continuous refactoring and turns the dials up with AI-assisted review. The goal is not more generated code for its own sake. The goal is better code, produced faster, under active human judgment.

Kent Beck once asked, "What if we took all the good practices and turned the dials up to 11?" Web XP takes that instinct seriously on the web platform: AI tightens the feedback, review, and refactoring loops rather than replacing engineering judgment.

## Why It Exists

AI increases output rate. Without a real standard, it also increases inconsistency, hidden complexity, and maintenance debt.

Web XP exists to keep speed from dissolving into slop. It defines governing rules, reusable patterns, and review skills for applications built directly on the web platform, with an emphasis on code that remains clear, debuggable, and durable over time.

The point is not to recreate framework dependency in lighter clothing. Many framework abstractions solve problems introduced by the framework itself. Web XP keeps more of the system legible by working with the DOM and standardized Web APIs directly.

## What You Get

- **Governing standards** in `code-guidelines.md`: principles, named patterns, language rules, and formatting defaults.
- **Explanatory context** in `code-philosophy.md`: why the standards work, how framework-era assumptions weakened, and what replaces common abstractions.
- **Review and refactoring skills** for Claude Code: load the doctrine, audit a diff, review arbitrary code, or walk through fixes interactively.
- **Mechanical checks** in `bin/pre-commit-check.sh` for recurring violations such as inline handlers, hardcoded colors, loose equality, and junk-drawer filenames.

## What It Covers

Web XP is not just style guidance. Its concrete examples live in `code-philosophy.md`, especially around:

- routing and URL-driven navigation
- state ownership and lifetime
- explicit initialization and data fetching
- failure handling and graceful degradation
- DOM ownership, dispatch, and CSS-driven state

If you want the argument and examples first, start with `code-philosophy.md`. If you want the operational rules and named patterns first, start with `code-guidelines.md`.

## Claude Code Skill

First-time setup:

```bash
git clone https://github.com/GarrettS/code-guidelines.git ~/.claude/web-xp
mkdir -p ~/.claude/skills
rm -rf ~/.claude/skills/doctrine ~/.claude/skills/doctrine-init \
  ~/.claude/skills/doctrine-check ~/.claude/skills/doctrine-apply \
  ~/.claude/skills/doctrine-review ~/.claude/skills/code-guidelines.md \
  ~/.claude/skills/code-philosophy.md ~/.claude/skills/pre-commit-check.sh
cp -r ~/.claude/web-xp/.claude/skills/* ~/.claude/skills/
```

To update later:

```bash
cd ~/.claude/web-xp && git pull
rm -rf ~/.claude/skills/doctrine ~/.claude/skills/doctrine-init \
  ~/.claude/skills/doctrine-check ~/.claude/skills/doctrine-apply \
  ~/.claude/skills/doctrine-review ~/.claude/skills/code-guidelines.md \
  ~/.claude/skills/code-philosophy.md ~/.claude/skills/pre-commit-check.sh
cp -r ~/.claude/web-xp/.claude/skills/* ~/.claude/skills/
```

Then in Claude Code:

- `/doctrine` — load the standards into the session
- `/doctrine-review` — review code against the doctrine
- `/doctrine-check` — audit the current diff
- `/doctrine-apply` — walk through fixes one at a time

## Git Submodule

If you just want to use Web XP in Claude Code, the skill path above is simpler. Use the submodule path when you want the doctrine files present inside your own repository for direct references, pinned revisions, or project-specific doctrine work:

```bash
git submodule add https://github.com/GarrettS/code-guidelines.git .doctrine
```

The doctrine files and skills live in `.doctrine/`. The hosting project records a specific doctrine commit.

A submodule gives your project a local snapshot of the doctrine, and snapshots drift. To avoid version drift, add a note to your project's `project.md` telling Claude to check whether `.doctrine` is behind the canonical `code-guidelines` repository before major work, at periodic commits, and when pulling upstream doctrine changes.

A practical way to reinforce this is `bin/check-doctrine-sync.sh`, a lightweight pre-commit warning that checks at most once daily. Copy it into your project's `bin/` and call it from your pre-commit script:

```bash
cp .doctrine/bin/check-doctrine-sync.sh bin/
# In your pre-commit script:
bash bin/check-doctrine-sync.sh
```

To update a consuming project:

```bash
cd .doctrine
git pull origin main
cd ..
git add .doctrine
git commit -m "Update doctrine"
```

If you want the project-local rule set first:

- read `.doctrine/code-guidelines.md` for the governing rules and named patterns
- read `.doctrine/code-philosophy.md` for the examples and explanatory context
- use `/doctrine-check` and `/doctrine-apply` inside the project workflow

## Claude Commands

Five slash commands for loading, inspecting, auditing, and refactoring:

| Skill | Description |
|-------|-------------|
| `/doctrine` | Load the governing rules into the current session |
| `/doctrine-init` | Project setup - creates starter `CLAUDE.md` and pre-commit script |
| `/doctrine-check` | Read-only audit of the current diff against doctrine patterns |
| `/doctrine-apply` | Interactive refactoring - walks through findings one at a time with approval |
| `/doctrine-review` | Inspect any code: pasted snippets, file paths, or framework code |

## Workflow Strategy

For AI-assisted development under active human review. The standards constrain AI output and provide a shared vocabulary for correction and refactoring. They are most effective in the hands of an experienced developer who can recognize when the AI is structurally right, mechanically wrong, or conceptually off-base.

Each rule traces back to a specific failure observed during development. When the AI produces an anti-pattern, do not just fix the code. Tighten the rule so the failure is easier to catch the next time.

## Canonical Workflow

This repository is the canonical source for Web XP.

When changing Web XP itself:

1. Edit and commit in a working clone of `code-guidelines`.
2. Push the change to the canonical GitHub repository.
3. Update any consuming project that vendors the doctrine as a submodule.
4. Commit the submodule pointer update in that parent project separately.

Changing the doctrine and updating a consuming project to use that change are separate repository changes.

## License

MIT
