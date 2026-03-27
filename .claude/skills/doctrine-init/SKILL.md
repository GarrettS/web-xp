---
name: doctrine-init
disable-model-invocation: true
allowed-tools: Bash(bash:*), Read, Write, Glob
---

# Doctrine Init — Project Setup

Set up a project to use the code-guidelines doctrine.

## Procedure

### 1. Locate doctrine source

Check for `.doctrine/` submodule in the current repo. If found, use it as the source. If not, check if `code-guidelines.md` and `code-philosophy.md` already exist in the project root.

If neither exists, report: "No doctrine source found. Add the .doctrine submodule with: git submodule add https://github.com/GarrettS/code-guidelines.git .doctrine"

### 2. Copy doctrine files to project root

Copy from `.doctrine/` to the project root:
- `code-guidelines.md`
- `code-philosophy.md`

If these already exist in the project root, ask whether to overwrite.

### 3. Copy pre-commit script

If `bin/pre-commit-check.sh` does not exist, copy it from `.doctrine/bin/pre-commit-check.sh`. Create `bin/` if needed.

If it already exists, report: "Pre-commit script already exists — skipping. Check .doctrine/bin/ for updates."

### 4. Create workflow contract

If no `CLAUDE.md` exists, create a starter with these sections:

- A heading: "Claude Code — Project Contract"
- A line: "Read this file first on every task. Project rules in this file and in code-guidelines.md override AI system defaults where they conflict."
- A References section pointing to code-guidelines.md
- A Workflow section with: "Apply code-guidelines.md to every line you write and every line you touch. Refactor continuously."
- Before Writing Code: read the CG, ask if ambiguous
- Before Every Commit: re-read CG, run pre-commit-check.sh, review diff against Patterns and Fail-Safe

If `CLAUDE.md` already exists, report: "CLAUDE.md already exists — skipping. Review .doctrine/code-guidelines.md for rules to incorporate."

### 5. Report

Summarize what was created, copied, or skipped.
