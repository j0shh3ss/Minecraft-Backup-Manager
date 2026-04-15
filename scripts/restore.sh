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
echo "==== Minecraft Backup Restore ===="

# ---- USER INPUT ----

read -p "Tmux session name [Minecraft]: " SESSION
SESSION=${SESSION:-Minecraft}

read -p "Minecraft server root directory (contains world/, versions/, config/, etc.): [/mnt/server/minecraft]: " SERVER_DIR
SERVER_DIR=${SERVER_DIR:-/mnt/server/minecraft}

read -p "Path to backup file (.tar.zst): " BACKUP_FILE

# ---- VALIDATION ----

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found!"
    exit 1
fi

if [[ "$SERVER_DIR" == "/" || -z "$SERVER_DIR" ]]; then
    echo "Refusing to operate on invalid directory"
    exit 1
fi

if [ ! -d "$SERVER_DIR/world" ]; then
    echo "❌ ERROR: '$SERVER_DIR' does not contain a world/ directory"
    echo "You likely entered the wrong directory."
    exit 1
fi

echo ""
echo "⚠️ WARNING: This will OVERWRITE your current server files!"
read -p "Continue? (y/n): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

# ---- TEMP DIR ----

TMP_DIR="/tmp/mc-restore-$(date +%s)"
mkdir -p "$TMP_DIR"

echo "Using temp directory: $TMP_DIR"

# ---- STOP SAVING ----
tmux has-session -t "$SESSION" 2>/dev/null || {
    echo "❌ tmux session '$SESSION' not found"
    exit 1
}

tmux send-keys -t "$SESSION" "say Server restore starting..." Enter || true
sleep 3
tmux send-keys -t "$SESSION" "save-all flush" Enter || true
sleep 3
tmux send-keys -t "$SESSION" "save-off" Enter || true
sleep 3

# ---- EXTRACT BACKUP ----

echo "Extracting backup..."
tar -I zstd -xf "$BACKUP_FILE" -C "$TMP_DIR"

# Detect if backup contains a world folder
if [ ! -d "$TMP_DIR/world" ]; then
    echo "❌ ERROR: Backup does not contain a world/ directory"
    exit 1
fi

# ---- RESTORE FILES ----

echo "Restoring files..."

# This removes current server files (but keeps the main directory)
find "$SERVER_DIR" -mindepth 1 -delete

# Copy restored files into place
cp -a "$TMP_DIR"/. "$SERVER_DIR/"

# ---- CLEANUP ----

rm -rf "$TMP_DIR"

# ---- RE-ENABLE SAVING ----

tmux send-keys -t "$SESSION" "save-on" Enter || true
sleep 3
tmux send-keys -t "$SESSION" "say Restore complete!" Enter || true

echo ""
echo "✅ Restore complete!"
echo "Your server files have been replaced with:"
echo "$BACKUP_FILE"