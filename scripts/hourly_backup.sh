#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/backup.conf"

if [ ! -f "$CONFIG" ]; then
    echo "❌ Missing config file: $CONFIG"
    echo "Run install.sh first."
    exit 1
fi

source "$CONFIG"

command -v tmux >/dev/null || { echo "tmux not installed"; exit 1; }
command -v zstd >/dev/null || { echo "zstd not installed"; exit 1; }
command -v tar >/dev/null || { echo "tar not installed"; exit 1; }

TIMESTAMP=$(date +"%Y-%m-%d_%H")
TMP_DIR="$BACKUP_BASE/tmp_$TIMESTAMP"

#Validate tmux session exists
tmux has-session -t "$SESSION" 2>/dev/null || {
    echo "❌ tmux session '$SESSION' not found"
    exit 1
}

trap 'tmux send-keys -t "$SESSION" "save-on" Enter || true' EXIT

# Ensure destination exists
mkdir -p "$HOURLY_DIR" "$TMP_DIR" "$LOG_DIR"

tmux send-keys -t "$SESSION" "say Hourly Backup Starting..." Enter || true
sleep 5
tmux send-keys -t "$SESSION" "save-all flush" Enter || true
sleep 5
tmux send-keys -t "$SESSION" "save-off" Enter || true
sleep 5

#copy

rsync -a --delete "$MC_DIR/" "$TMP_DIR/"

tmux send-keys -t "$SESSION" "save-on" Enter || true
sleep 5

#compress
#can change "server_hourly" in the output filename if desired, this does NOT affect what gets backed up.
tar -I 'zstd -10' -cf \
"$HOURLY_DIR/server_hourly-$TIMESTAMP.tar.zst" \
-C "$TMP_DIR" .

#cleanup temp
rm -rf "$TMP_DIR"

tmux send-keys -t "$SESSION" "say Hourly Backup Complete" Enter || true

#cleanup dir, change 1500 to change how long you want to keep hourly backups in minutes, 1500 minutes is 25 hours, so this will keep hourly backups for a little over a day. This is because daily backups are made every 24 hours, so this will ensure that there is always at least one hourly backup available before the next daily backup is made.
find "$HOURLY_DIR" -type f -mmin +1500 -delete || true

echo "[$(date -Iseconds)] Hourly backup completed" >> "$LOG_DIR/backup_hourly.log"