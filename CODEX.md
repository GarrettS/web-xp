# Codex — Web XP Project Contract

Read this file first on every task.

## On every session

If the task involves JS, HTML, or CSS, read `code-guidelines.md` and `code-philosophy.md` before writing or reviewing code.

## Standards files

Canonical sources live at repo root (`code-guidelines.md`, `code-philosophy.md`, `bin/pre-commit-check.sh`) and in `adapters/codex/` for Codex adapter source. Edit the canonical source, not generated outputs.

## Before every commit

1. Run `bash tools/check-web-xp-sync.sh`.
2. Review the diff against Patterns and Fail-Safe in `code-guidelines.md`.
3. Run `bash bin/pre-commit-check.sh`.

## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `internal/AGENT-HANDOFF.md`.

`check` and `chk` mean: read `/tmp/web-xp-agent-handoff/claude-to-codex.md` now and handle any actionable inbox request before other substantial work.

If the inbox contains an actionable request, do that inbox work before any other substantial task and before replying elsewhere.

Before substantial work and before replying:
1. Read `/tmp/web-xp-agent-handoff/claude-to-codex.md` (your inbox).
2. Write to `/tmp/web-xp-agent-handoff/codex-to-claude.md` (your outbox).
3. Do not read `/tmp/web-xp-agent-handoff/codex-to-claude.md` for incoming messages.
4. Do not assume terminal output or chat context has been shared across agents; write important context to the handoff files.
