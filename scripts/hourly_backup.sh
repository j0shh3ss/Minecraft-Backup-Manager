#!/bin/bash

# Change MC_DIR to match your server directory (the folder containing your world)

# What each variable is for:
# Session = Tmux session name of the server you want to backup. This is used to send commands to the server to save and stop saving while copying files.
# MC_DIR = The directory where your Minecraft server files are located. This should be the directory that contains the world folder and other server files.
# BACKUP_DIR = The directory where you want to store the hourly backups. This should be a different location than the server files to prevent issues with copying while the server is running.
# TIMESTAMP = DO NOT CHANGE! A timestamp to append to the backup filename. This is used to keep track of when each backup was made.
# TMP_DIR = A temporary directory to copy the server files to before compressing. This is used to prevent issues with copying while the server is running. This should also be a different location than the server files.
# LOG_DIR = The directory where you want to store the backup logs. This should be a different location than the server files to prevent issues with copying while the server is running.

set -euo pipefail

command -v tmux >/dev/null || { echo "tmux not installed"; exit 1; }
command -v zstd >/dev/null || { echo "zstd not installed"; exit 1; }
command -v tar >/dev/null || { echo "tar not installed"; exit 1; }

SESSION="Minecraft"
MC_DIR="/mnt/server/minecraft/world"
BACKUP_DIR="/mnt/server/minecraft/backups/hourly"
TIMESTAMP=$(date +"%Y-%m-%d_%H")
TMP_DIR="/mnt/server/minecraft/backups/tmp_$TIMESTAMP"
LOG_DIR="/mnt/server/minecraft/backups/logs"

exec >> /var/log/mc-backup-hourly.log 2>&1

trap 'tmux send-keys -t "$SESSION" "save-on" Enter || true' EXIT

# Ensure destination exists
mkdir -p "$BACKUP_DIR" "$TMP_DIR" "$LOG_DIR"

tmux send-keys -t "$SESSION" "say Hourly Backup Starting..." Enter || true
sleep 5
tmux send-keys -t "$SESSION" "save-all flush" Enter || true
sleep 5
tmux send-keys -t "$SESSION" "save-off" Enter || true
sleep 5

#copy

cp -a "$MC_DIR/" "$TMP_DIR/"

tmux send-keys -t "$SESSION" "save-on" Enter || true
sleep 5

#compress
#Can change world before _hourly to the name of your world, this is just the name of the backup file and does not affect the backup process.
tar -I 'zstd -10' -cf \
"$BACKUP_DIR/world_hourly-$TIMESTAMP.tar.zst" \
-C "$TMP_DIR" .

#cleanup temp
rm -rf "$TMP_DIR"

tmux send-keys -t "$SESSION" "say Hourly Backup Complete" Enter || true
sleep 5

#cleanup dir, change 1500 to change how long you want to keep hourly backups in minutes, 1500 minutes is 25 hours, so this will keep hourly backups for a little over a day. This is because daily backups are made every 24 hours, so this will ensure that there is always at least one hourly backup available before the next daily backup is made.
find "$BACKUP_DIR" -type f -mmin +1500 -delete || true

echo "$(date): Hourly backup completed." >> "$LOG_DIR/backup_hourly.log"