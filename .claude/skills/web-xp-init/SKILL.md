---
name: web-xp-init
description: "Set up a project with Web XP standards. Trigger: 'set up project', 'initialize', 'create CLAUDE.md', 'add pre-commit', 'init web-xp'."
---

# Web XP Init — Project Setup

Set up a project to use the Web XP standards skill.

## Procedure

### 1. Copy pre-commit script

If `bin/pre-commit-check.sh` does not exist in the project, copy it using `cp ${CLAUDE_SKILL_DIR}/../pre-commit-check.sh bin/pre-commit-check.sh`. Create `bin/` if needed.

If it already exists, report: "Pre-commit script already exists — skipping."

### 2. Create workflow contract

If no `CLAUDE.md` exists, create a starter. The content depends on how the project consumes the standards:

**Submodule consumer** (`.web-xp/` directory exists):

```markdown
# Claude Code — Project Contract

Read this file first on every task.

## On every session

If the task involves JS, HTML, or CSS, read `.web-xp/code-guidelines.md` before writing or reviewing code. Read `.web-xp/code-philosophy.md` for explanatory context when needed.

## Before every commit

1. Run `bash .web-xp/bin/pre-commit-check.sh` — catches mechanical violations.
2. Review the diff against Patterns and Fail-Safe in `.web-xp/code-guidelines.md`.
```

**Skill consumer** (no `.web-xp/` directory):

```markdown
# Claude Code — Project Contract

Read this file first on every task.

## On every session

If the task involves JS, HTML, or CSS, run `/web-xp` before writing or reviewing code.

## Before every commit

1. Run `/web-xp-check` — audit the diff against Web XP patterns.
2. Run `bash bin/pre-commit-check.sh` — catches mechanical violations.
```

If `CLAUDE.md` already exists, report: "CLAUDE.md already exists — skipping."

### 3. Report

Summarize what was created, copied, or skipped.
