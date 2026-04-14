#!/bin/bash

set -euo pipefail

echo "==== Minecraft Backup Restore ===="

# ---- USER INPUT ----

read -p "Tmux session name [Minecraft]: " SESSION
SESSION=${SESSION:-Minecraft}

read -p "Minecraft server directory [/mnt/server/minecraft]: " SERVER_DIR
SERVER_DIR=${SERVER_DIR:-/mnt/server/minecraft}

read -p "Path to backup file (.tar.zst): " BACKUP_FILE

# ---- VALIDATION ----

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found!"
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

tmux send-keys -t "$SESSION" "say Server restore starting..." Enter || true
sleep 3
tmux send-keys -t "$SESSION" "save-all flush" Enter || true
sleep 3
tmux send-keys -t "$SESSION" "save-off" Enter || true
sleep 3

# ---- EXTRACT BACKUP ----

echo "Extracting backup..."
tar -I zstd -xf "$BACKUP_FILE" -C "$TMP_DIR"

# ---- RESTORE FILES ----

echo "Restoring files..."

# This removes current server files (but keeps the main directory)
find "$SERVER_DIR" -mindepth 1 -delete

# Copy restored files into place
cp -a "$TMP_DIR/"* "$SERVER_DIR/"

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