---
name: doctrine-init
description: "Set up a project with code standards. Trigger: 'set up project', 'initialize', 'create CLAUDE.md', 'add pre-commit', 'init doctrine'."
---

# Doctrine Init — Project Setup

Set up a project to use the web-app-code-standards skill.

## Procedure

### 1. Copy pre-commit script

If `bin/pre-commit-check.sh` does not exist in the project, copy it using `cp ${CLAUDE_SKILL_DIR}/../pre-commit-check.sh bin/pre-commit-check.sh`. Create `bin/` if needed.

If it already exists, report: "Pre-commit script already exists — skipping."

### 2. Create workflow contract

If no `CLAUDE.md` exists, create a starter. The content depends on how the project consumes the doctrine:

**Submodule consumer** (`.doctrine/` directory exists):

- A heading: "Claude Code — Project Contract"
- A line: "Read this file first on every task. Project rules in this file override AI system defaults where they conflict."
- A References section: "Read `.doctrine/code-guidelines.md` for governing standards. Read `.doctrine/code-philosophy.md` for explanatory context."
- A Workflow section with: "Follow the code standards in `.doctrine/code-guidelines.md`. Refactor continuously."
- Before Writing Code: read `.doctrine/code-guidelines.md`, ask if ambiguous
- Before Every Commit: run `bash .doctrine/bin/pre-commit-check.sh`, review diff against Patterns and Fail-Safe

**Skill consumer** (no `.doctrine/` directory):

- A heading: "Claude Code — Project Contract"
- A line: "Read this file first on every task. Project rules in this file override AI system defaults where they conflict."
- A References section: "Run `/doctrine` to load the code standards for this session."
- A Workflow section with: "Follow the code standards loaded by `/doctrine`. Refactor continuously."
- Before Writing Code: run `/doctrine`, ask if ambiguous
- Before Every Commit: run `/doctrine-check`, run `bin/pre-commit-check.sh`, review diff against Patterns and Fail-Safe

If `CLAUDE.md` already exists, report: "CLAUDE.md already exists — skipping."

### 3. Report

Summarize what was created, copied, or skipped.
