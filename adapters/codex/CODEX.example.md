# Codex Project Contract

Read this file first on every task.

## On every session

If the task involves JS, HTML, or CSS, read `code-guidelines.md` and `code-philosophy.md` from your Web XP install (`~/.web-xp/`) before writing or reviewing code.

## Web XP spec directory

Treat `~/.web-xp/adapters/codex/` as the Web XP spec directory. When asked to follow a spec (e.g. `web-xp-check.md`), read it from that directory.

## Before every commit

1. Run `bash ~/.web-xp/bin/pre-commit-check.sh` — catches mechanical violations.
2. Review the diff against Patterns and Fail-Safe in `~/.web-xp/code-guidelines.md`.

## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `AGENT-HANDOFF.md`.

Before substantial work and before replying:
1. Check whether `AGENT-HANDOFF.md`, `agent-handoff/inbox-codex.md`, and any collaboration-relevant outbox files (for example `agent-handoff/outbox-claude.md`) changed since last read.
2. If any changed, re-read them.
3. If no prior read state is available, read them.

For Claude collaboration:
- Check `agent-handoff/outbox-claude.md` before asking the user for information Claude may already have provided.
- Write findings, status updates, and requests to `agent-handoff/outbox-codex.md`.
- Do not assume terminal output or chat context has been shared across agents; write important context to the handoff files.
