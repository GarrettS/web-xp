# Orchestration — Design Notes

Design artifact capturing orchestration needs observed during Web XP development. Not implemented. If this becomes a real project, it likely lives outside this repo.

---

## The Problem

Multi-agent development workflows today run on manual relay. In the current Web XP workflow:

- Claude writes code and checks its own work
- Codex reviews via file-based handoff (inbox/outbox markdown files)
- The human polls, relays, reminds agents to check messages
- There is no task ordering, no automatic handoff, no retry logic

This works but is fragile. The human is the scheduler, the router, and the error handler.

## What We Have Today

### Tasks

| Task | Type | Interface |
|------|------|-----------|
| `pre-commit-check.sh` | Script | Exit 0/1, stdout findings |
| `/web-xp-check` (Claude) | Agent skill | Reads diff, reports findings |
| `web-xp-check.md` (Codex) | Agent spec | Same behavior, different invocation |
| `/web-xp-review` | Agent skill/spec | Reviews arbitrary code |
| `/web-xp-apply` | Agent skill/spec | Applies fixes with approval |

### Communication

| Mechanism | What it does | Limitation |
|-----------|-------------|------------|
| `agent-handoff/` files | Async message passing between agents | No notification — requires polling or manual relay |
| `AGENT-HANDOFF.md` | Human-readable contract for file-based handoff workflow | Agents can't self-invoke |
| Contract files (`CLAUDE.md`, `CODEX.md`) | Session directives | Read once at session start, not reactive |

### What's missing

- **Task ordering**: no way to say "run A, then B, then C"
- **Conditional flow**: no way to say "if review fails, loop back to code"
- **Agent handoff**: no way to say "when Claude finishes, hand to Codex"
- **Subtask delegation**: no way to say "Codex, spawn a Qwen task for testing"
- **Notification**: agents can't wake each other — the human has to relay

## Orchestration Patterns Observed

### Linear chain

```
eslint → web-xp mechanical check → web-xp structural review → deploy
```

Exists today as manual sequences in contract files. Works if one agent does everything.

### Back-and-forth review

```
Claude: code → Codex: review → Claude: fix → Codex: re-review
```

This is what we did during the Codex adapter development. Ran on manual file handoff and human relay. The protocol (inbox/outbox) handled the format; the human handled the scheduling.

### Subtask delegation

```
Codex: document → Qwen: test (subtask) → Codex: integrate results
```

Not attempted yet. Would require one agent to invoke another, which no current mechanism supports without the human.

### Plan-driven workflow

```
Claude: plan → Claude: code → Codex: review + doc → Qwen: test
```

A graph, not a chain. Some steps are sequential, some are parallel, some loop.

## What a Solution Would Look Like

### Task interface

Every task — script or agent — has the same minimal interface:

- **Input**: working directory, optional scope (files, diff)
- **Output**: exit code (0 = pass, nonzero = fail), stdout for findings
- **Control**: caller decides whether failure stops the chain

### Composition primitives

- **Sequence**: run A then B
- **Conditional**: if A fails, run B instead of C
- **Loop**: run A and B until B passes
- **Parallel**: run A and B simultaneously
- **Delegation**: A spawns B as a subtask (crosses actor boundaries, not just task boundaries)

### What runs it

Options, from simple to complex:

1. **Shell script**: sequences tasks manually. Works for linear chains.
2. **Agent contract**: the "Before every commit" section is already a task list. The agent is the runner.
3. **Declarative config**: a YAML/JSON file defining the task graph. Needs a runner to interpret it.
4. **Workflow engine**: Temporal, Airflow-style. Overkill for this context.
5. **smux**: tmux-based agent coordination. Handles the "notification" problem — agents in panes can message each other via `tmux-bridge`.

### Where existing tools cover

| Tool | Covers | Doesn't cover |
|------|--------|---------------|
| Make | Task ordering, dependency graphs | Agent invocation, loops, handoff |
| CI (GitHub Actions) | Sequence, parallel, conditional | Agent sessions, interactive approval |
| Shell scripts | Sequence, conditional | Agent communication, subtasks |
| smux/tmux-bridge | Agent messaging, pane management | Task ordering, failure handling |
| Agent contracts | Session directives, task lists | Cross-agent coordination, loops |

The gap is at the intersection: task ordering + agent communication + failure handling.

## Scope Question

This is bigger than Web XP. Web XP is one task provider. The orchestration system would serve any multi-agent, multi-tool workflow.

If built, it should be a separate project that Web XP plugs into — not a feature of Web XP.

## What Web XP Should Do Now

1. Be a good task citizen: clean interfaces, documented exit semantics
2. Document task composition examples in README
3. Keep the file-based handoff protocol as the current agent communication layer
4. Not build an orchestration engine

## If This Becomes a Project

It would need:

- A task definition format (what to run, what it needs, what it produces)
- A composition format (task graph definition)
- A runner (interprets the graph, invokes tasks, handles failure)
- Agent integration (invoke agents, wait for results, relay findings)
- Notification (wake agents when their input is ready)

That's a real project, not a feature.
