# smux Dev Workflow Spike

Experimental contributor tooling for reducing manual agent relay during Web XP development.

## Status

First spike implemented. Two complementary tools:

1. **`bin/tmux-bridge`** — active CLI for pane discovery, role registration, and handoff prompt delivery
2. **`dev-relay.sh`** — passive file watcher that monitors handoff files and notifies on changes

## What it proves

- One pane can identify another by role (`codex`, `claude`)
- A handoff can auto-send the next prompt into the target pane
- Agents can escalate to the human via terminal bell + macOS notification
- Background polling catches changes even when neither agent actively sends

## Flow

```
Human → Claude → Codex → Claude → Human
```

1. Human gives Claude a task
2. Claude works, writes to outbox, runs `tmux-bridge handoff codex` (auto-sends)
3. Codex pane receives the prompt via `tmux send-keys`, reviews, writes to outbox, runs `tmux-bridge handoff claude` (auto-sends)
4. Claude acts on review, runs `tmux-bridge escalate claude "Ready for review"` when done
5. Human sees notification in their pane, replies with `tmux-bridge handoff claude "approved"` or `tmux-bridge handoff codex "fix X"`

## Files

- `bin/tmux-bridge`: tmux helper CLI — register roles, notify, paste, handoff
- `dev-relay.sh`: background watcher — polls handoff files, emits notifications on change
- `CLAUDE-PROMPT.md`: session prompt for Claude
- `CODEX-PROMPT.md`: session prompt for Codex

## Usage

### tmux-bridge (active relay)

From inside a tmux session:

```bash
contrib/smux/bin/tmux-bridge list
contrib/smux/bin/tmux-bridge register human %0
contrib/smux/bin/tmux-bridge register codex %1
contrib/smux/bin/tmux-bridge register claude %2
contrib/smux/bin/tmux-bridge handoff codex "Review the latest note from Claude."
contrib/smux/bin/tmux-bridge handoff claude "Codex replied in the handoff log."
```

`handoff codex` pastes:

```text
Read /absolute/path/to/agent-handoff/claude-to-codex.md and continue from there.
```

`handoff claude` pastes:

```text
Read /absolute/path/to/agent-handoff/codex-to-claude.md, act on it, and restart the poll.
```

### dev-relay (passive watcher)

Run in a separate terminal pane:

```bash
bash contrib/smux/dev-relay.sh              # default: poll every 3s
bash contrib/smux/dev-relay.sh --interval 5  # custom interval
```

Emits timestamped terminal notifications when either handoff file changes. On macOS, also attempts a system notification (best-effort).

## Commands (tmux-bridge)

- `list`: show panes across tmux sessions with IDs and current commands
- `register <role> <pane-id>`: map `codex` or `claude` to a pane
- `roles`: print the current role registry
- `notify <role|pane-id> <message>`: show a tmux status-line message in a pane
- `paste <role|pane-id> <text>`: paste text into a pane without executing it
- `handoff <codex|claude> [note]`: notify the pane, paste a standard inbox-check prompt, and auto-send
- `escalate <from-role> <message>`: notify the human pane with bell + macOS notification, tagged with which agent is asking

## State

Role mappings are stored outside the repo by default:

```text
~/.web-xp/smux/roles.tsv
```

Override with `SMUX_ROLE_FILE` if needed.

Poll state for dev-relay is stored in `.dev-relay/` at the repo root (gitignored).

## Assumptions

- Each agent runs in a **dedicated tmux pane** (single-purpose, no shared shells)
- `handoff` auto-sends via `tmux send-keys Enter` — unsafe outside dedicated panes
- This is terminal-input automation in a constrained local workflow, not a supported autonomous agent wakeup mechanism

## Non-goals

- General orchestration engine
- User-facing feature
- Fully unattended operation (human should be reachable via escalate)
