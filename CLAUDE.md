# Claude Code — Web XP Project Contract

Read this file first on every task.

## On every session

If the task involves JS, HTML, or CSS, run `/web-xp` before writing or reviewing code.

## Standards files

Canonical skill sources live in `adapters/shared-base/skills/`. Generated adapter packaging lives in `adapters/claude/` and `adapters/codex/skills/`. Always edit the shared source, never generated adapter output.

`.claude/skills/` is gitignored — it is populated by `bin/install.sh` at install time, not tracked in the repo.

## Before every commit

1. Run `bash tools/check-web-xp-sync.sh` — rebuilds generated adapter skills from shared sources.
2. Run `/web-xp-check` — audit the diff against Web XP patterns.
3. Run `bash bin/pre-commit-check.sh` — catches mechanical code-guideline violations.

## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `internal/AGENT-HANDOFF.md`.

Before substantial work and before replying:
1. Read `/tmp/web-xp-agent-handoff/codex-to-claude.md` (your inbound file).
2. Write to `/tmp/web-xp-agent-handoff/claude-to-codex.md` (your outbound file).
3. Do not assume terminal output or chat context has been shared across agents; write important context to the handoff files.

When the human says **check** or **chk**: read `/tmp/web-xp-agent-handoff/codex-to-claude.md` immediately and handle actionable inbox work before other substantial work.

## Edit tool

When changing multiple locations in the same file, use one Edit call with an `old_string` span that covers all change sites. Never send parallel Edit calls to the same file.
