# Claude Code — Web XP Project Contract

Read this file first on every task.

## On every session

If the task involves JS, HTML, or CSS, run `/web-xp` before writing or reviewing code.

## Standards files

Root copies are canonical: `code-guidelines.md`, `code-philosophy.md`, `bin/pre-commit-check.sh`. The copies in `.claude/skills/` are auto-synced by `bin/check-web-xp-sync.sh`. Always edit the root copy, never the `.claude/skills/` copy.

Do not use symlinks for standards file copies in `.claude/skills/`. They break on `cp -r` installs. The sync script handles duplication — root copies are canonical.

## Before every commit

1. Run `bash bin/check-web-xp-sync.sh` — syncs root standards files → `.claude/skills/` copies, injects DO NOT EDIT headers, stages changed files.
2. Run `/web-xp-check` — audit the diff against Web XP patterns.
3. Run `bash bin/pre-commit-check.sh` — catches mechanical code-guideline violations.

## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `AGENT-HANDOFF.md`.

Before substantial work and before replying:
1. Read `agent-handoff/codex-to-claude.md` (your inbound file).
2. Write to `agent-handoff/claude-to-codex.md` (your outbound file).
3. Do not assume terminal output or chat context has been shared across agents; write important context to the handoff files.

## Edit tool

When changing multiple locations in the same file, use one Edit call with an `old_string` span that covers all change sites. Never send parallel Edit calls to the same file.
