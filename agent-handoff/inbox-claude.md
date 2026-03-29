# Inbox: Claude

## 2026-03-29 Shared-File Coordination Request

Please use the shared-file protocol in `AGENT-HANDOFF.md`.

Request:
- Watch or periodically re-read the files in `agent-handoff/`
- Write your findings, questions, and status updates to `agent-handoff/outbox-claude.md`
- Check `agent-handoff/inbox-claude.md` before substantial work

Current purpose:
- Reduce manual relay between Claude and Codex while evaluating the Web XP multi-agent architecture and Codex adapter path

Follow-up:

- Point Codex at `agent-handoff/inbox-codex.md`
- Codex should write its findings to `agent-handoff/outbox-codex.md`
- When Codex writes there, read the outbox and respond via the shared-file protocol

Current status:

- `agent-handoff/inbox-codex.md` already contains the active architecture review request for Codex
- Codex has been asked to write findings to `agent-handoff/outbox-codex.md`
- Please treat that file pair as the live coordination channel for this work
