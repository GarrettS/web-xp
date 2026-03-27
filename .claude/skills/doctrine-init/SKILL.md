---
name: doctrine-init
description: "Project setup — creates starter CLAUDE.md and copies pre-commit script from the code standards."
---

# Doctrine Init — Project Setup

Set up a project to use the web-app-code-standards skill.

## Procedure

### 1. Copy pre-commit script

If `bin/pre-commit-check.sh` does not exist in the project, copy it using `cp ${CLAUDE_SKILL_DIR}/../pre-commit-check.sh bin/pre-commit-check.sh`. Create `bin/` if needed.

If it already exists, report: "Pre-commit script already exists — skipping."

### 2. Create workflow contract

If no `CLAUDE.md` exists, create a starter with these sections:

- A heading: "Claude Code — Project Contract"
- A line: "Read this file first on every task. Project rules in this file override AI system defaults where they conflict."
- A References section: "Run `/doctrine` to load the code standards for this session."
- A Workflow section with: "Follow the code standards loaded by `/doctrine`. Refactor continuously."
- Before Writing Code: run `/doctrine`, ask if ambiguous
- Before Every Commit: run `/doctrine-check`, run `bin/pre-commit-check.sh`, review diff against Patterns and Fail-Safe

If `CLAUDE.md` already exists, report: "CLAUDE.md already exists — skipping. Run `/doctrine` to load the code standards."

### 3. Report

Summarize what was created, copied, or skipped.
