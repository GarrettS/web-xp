# Dev Workflow Integration

This document defines the **contributor workflow problem** for building Web XP.

It is separate from product orchestration. The question here is not "how do we run user-defined workflows." The question is "how do the humans and agents building Web XP coordinate without wasting effort on manual relay."

This document is temporary by design.

It exists to clarify the current contributor workflow until the orchestration project is defined well enough to absorb this use case directly. If that project succeeds, the contributor workflow described here should become one concrete orchestration use case, and this document should be removed or reduced to a historical note.

## Problem

Today the build workflow relies on a durable markdown handoff plus a human router.

Typical loop:

```text
Claude writes -> Codex reviews -> Claude fixes -> Human approves
```

The markdown handoff works. The human-as-router does not.

The wasted steps are:

- "check your inbox"
- "the other agent replied"
- "continue from there"

Those are transport failures, not review work.

## Goal

Remove the human from message routing while keeping the human in control of:

- approvals
- exceptions
- priority changes
- shutdown

## What Already Works

- `/tmp/web-xp-agent-handoff/*.md` is a durable, inspectable message store
- both agents can read and write that store
- tmux-based notification and handoff have been validated in the spike

## What Is Still Missing

- reliable wakeup of the next actor
- clear escalation to the human
- explicit operating assumptions for unsafe automation
- a stable contract for when handoff happens and when escalation happens

## Design Direction

Treat this as:

```text
durable message store + notifier + simple handoff policy
```

Not:

```text
workflow engine
```

## Layer Model

### 1. Message store

Canonical communication record:

- `/tmp/web-xp-agent-handoff/*.md`

Properties:

- durable
- inspectable
- diffable
- easy for agents to consume

### 2. Notifier

Mechanism that wakes or alerts the next actor.

Current candidates:

- `tmux-bridge`
- `dev-relay.sh`
- Claude Code hooks
- OS notifications

### 3. Handoff policy

Rules such as:

- when to hand off automatically
- when to escalate
- when to stop and wait for a human
- what operating assumptions must hold for automated input injection

## Constraints

- Human approval remains mandatory where required
- Different agent runtimes have different wakeup capabilities
- Some automation is safe only in dedicated panes or sessions
- The durable message store must remain readable without the notifier
- Failure of the notifier must not destroy the handoff record

## Non-Goals

- General workflow definition
- Task graphs
- Dependency trees
- Retry semantics for arbitrary user workflows
- Turning contributor tooling into product surface

## Working Rule

The message store is the source of truth.

Notifier behavior is an optimization layer on top.

If notifier behavior fails, agents should still be able to recover from the markdown handoff alone.

## Open Questions

1. What notifier stack should be preferred in day-to-day use: tmux, hooks, watchers, or hybrid?
2. Which automations are acceptable by default, and which must be explicitly opt-in?
3. What is the cleanest human escalation path?
4. How much of this belongs in `internal/smux/` versus a more general contributor-integration layer?

## Short Version

Dev workflow integration is a contributor tooling problem.

Its job is to remove the human as message router while preserving:

- a durable handoff record
- human approval authority
- explicit assumptions around automation
