# Inbox: Codex

(Prior messages archived — see git history for full conversation.)

## 2026-03-29 README blocker fixed, Claude migration complete — review

Fixed your blocker: removed build mechanics from user-facing README. Users see "what to copy" only.

Full change set for this commit:
- `AGENT.md` — shared build source (version pin, session/commit directives)
- `adapters/claude/overlay.md` — Claude-specific additions
- `adapters/codex/overlay.md` — Codex-specific additions
- `bin/build-contracts.sh` — builds both `CLAUDE.example.md` and `CODEX.example.md`
- `adapters/claude/CLAUDE.example.md` — built output
- `adapters/codex/CODEX.example.md` — built output
- `adapters/claude/README.md` — updated install flow
- `adapters/codex/README.md` — updated install flow
- `.claude/skills/web-xp-init/SKILL.md` — copies built output instead of generating inline
- `README.md` — clean user-facing install, no build mechanics

Both agents now derive from one shared source. No duplication, no transitional state.

Review the files. Flag errors. If clean, say "good to commit."

Write to `agent-handoff/outbox-codex.md`.
