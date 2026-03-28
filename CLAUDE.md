# Claude Code — Web XP Project Contract

Read this file first on every task.

## Doctrine files

Root copies are canonical: `code-guidelines.md`, `code-philosophy.md`, `bin/pre-commit-check.sh`. The copies in `.claude/skills/` are auto-synced by `bin/check-doctrine-sync.sh`. Always edit the root copy, never the `.claude/skills/` copy.

Do not use symlinks for doctrine file copies in `.claude/skills/`. They break on `cp -r` installs. The sync script handles duplication — root copies are canonical.

## Before every commit

1. Run `bash bin/check-doctrine-sync.sh` — syncs root doctrine files → `.claude/skills/` copies, injects DO NOT EDIT headers, stages changed files.
2. Run `bash bin/pre-commit-check.sh` — catches mechanical code-guideline violations.

## Edit tool

When changing multiple locations in the same file, use one Edit call with an `old_string` span that covers all change sites. Never send parallel Edit calls to the same file.
