---
name: web-xp-init
description: "Set up a project with Web XP standards. Trigger: 'set up project', 'initialize', 'create CLAUDE.md', 'add pre-commit', 'init web-xp'."
---

# Web XP Init — Project Setup

Set up a project to use the Web XP standards skill.

## Procedure

### 1. Create workflow contract

If no `CLAUDE.md` exists, create a starter:

```markdown
# Claude Code — Project Contract

Read this file first on every task.

## On every session

If the task involves JS, HTML, or CSS, run `/web-xp` before writing or reviewing code.

## Before every commit

1. Run `/web-xp-check` — audit the diff against Web XP patterns.
2. Run `bash ~/.web-xp/bin/pre-commit-check.sh` — catches mechanical violations.
```

If `CLAUDE.md` already exists, report: "CLAUDE.md already exists — skipping."

### 2. Report

Summarize what was created or skipped.
