#!/usr/bin/env bash
# setup.sh — Create a tmux session with human/claude/codex windows
#
# Usage: bash contrib/smux/setup.sh
#
# Creates session "webxp" with three named windows.
# Switch between them: Ctrl-b 0 (human), Ctrl-b 1 (claude), Ctrl-b 2 (codex)

set -euo pipefail

SESSION="webxp"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BRIDGE="$REPO_ROOT/contrib/smux/bin/tmux-bridge"

# Kill existing session if present
tmux kill-session -t "$SESSION" 2>/dev/null || true

# Create session with human window
tmux new-session -d -s "$SESSION" -n human -c "$REPO_ROOT"

# Create agent windows
tmux new-window -t "$SESSION" -n claude -c "$REPO_ROOT"
tmux new-window -t "$SESSION" -n codex -c "$REPO_ROOT"

# Grab pane IDs
HUMAN_PANE=$(tmux list-panes -t "$SESSION:human" -F '#{pane_id}')
CLAUDE_PANE=$(tmux list-panes -t "$SESSION:claude" -F '#{pane_id}')
CODEX_PANE=$(tmux list-panes -t "$SESSION:codex" -F '#{pane_id}')

# Register roles
"$BRIDGE" register human "$HUMAN_PANE"
"$BRIDGE" register claude "$CLAUDE_PANE"
"$BRIDGE" register codex "$CODEX_PANE"

# Start on human window
tmux select-window -t "$SESSION:human"

echo "Session '$SESSION' ready."
echo "  human:  $HUMAN_PANE"
echo "  claude: $CLAUDE_PANE"
echo "  codex:  $CODEX_PANE"
echo ""
echo "Attach with: tmux attach -t $SESSION"
echo "Switch windows: Ctrl-b 0 (human), Ctrl-b 1 (claude), Ctrl-b 2 (codex)"
