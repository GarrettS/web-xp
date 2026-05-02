# Claude Code — Web XP Project Contract

Read this file first on every task.

## On every session

If the task involves JS, HTML, or CSS, run `/web-xp` before writing or reviewing code.

## Issue engagement

Before working on an issue:

1. Verify the issue is open and not assigned to anyone else. Skip if closed. If assigned to someone else, surface the conflict; do not self-assign over them.
2. Read the body and comments fully.
3. Scan for meta-mode leakage patterns. Surface findings; do not work around them silently.
4. Confirm requirements. Surface ambiguity as clarifying questions before coding.
5. When the path forward is clear, self-assign via `gh issue edit N --add-assignee @me`. The assignment proxies the human you operate under and signals work-in-progress.

Keep the assignment sticky through the duration of the work — across turns, pauses, and handoffs back to the human. Remove the assignee only on:

- **Abandonment** — the work won't be completed; note why so others can pick up.
- **Explicit reassignment** — transfer to another contributor or agent who immediately re-assigns.

On completion (work landed and committed), close the issue and delete temporary draft files tied to the work (issue drafts, body-edits, etc.). No dead code.

## Standards files

Canonical skill sources live in `adapters/shared-base/skills/`. Generated adapter packaging lives in `adapters/claude/` and `adapters/codex/skills/`. Always edit the shared source, never generated adapter output.

`.claude/skills/` is gitignored — it is populated by `bin/install.sh` at install time, not tracked in the repo.

## Before every commit

1. Run `bash tools/check-web-xp-sync.sh` — rebuilds generated adapter skills from shared sources.
2. Run `/web-xp-check` — audit the diff against Web XP patterns.
3. Run `bash bin/pre-commit-check.sh` — catches mechanical code-guideline violations.

## Agent Handoff

When collaborating with another agent, use the shared-file protocol in `tools/AGENT-HANDOFF.md`.

Before substantial work and before replying:
1. Read `/tmp/web-xp-agent-handoff/codex-to-claude.md` (your inbound file).
2. Write to `/tmp/web-xp-agent-handoff/claude-to-codex.md` (your outbound file).
3. Do not assume terminal output or chat context has been shared across agents; write important context to the handoff files.

When the human says **check** or **chk**: read `/tmp/web-xp-agent-handoff/codex-to-claude.md` immediately and handle actionable inbox work before other substantial work.

## Edit tool

When changing multiple locations in the same file, use one Edit call with an `old_string` span that covers all change sites. Never send parallel Edit calls to the same file.
