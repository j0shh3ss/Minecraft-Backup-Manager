#!/bin/bash

set -euo pipefail


echo "==== Minecraft Backup Script Installer ===="

# ---- USER INPUT ----

read -p "Tmux session name [Minecraft]: " SESSION
SESSION=${SESSION:-Minecraft}

echo "Current directory is: $(pwd)"

read -p "Path to your server root folder (Where /world, /plugins, /config, etc. are located) [/mnt/server/minecraft]: " MC_DIR
MC_DIR=${MC_DIR:-/mnt/server/minecraft}

read -p "Backup base directory (Where backups will be stored) [/mnt/server/minecraft/backups]: " BACKUP_BASE
BACKUP_BASE=${BACKUP_BASE:-/mnt/server/minecraft/backups}

# Derived paths
HOURLY_DIR="$BACKUP_BASE/hourly"
DAILY_DIR="$BACKUP_BASE/daily"
WEEKLY_DIR="$BACKUP_BASE/weekly"
LOG_DIR="$BACKUP_BASE/logs"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/backup.conf"

echo ""
echo "Using configuration:"
echo "SESSION=$SESSION"
echo "MC_DIR=$MC_DIR"
echo "BACKUP_BASE=$BACKUP_BASE"
echo ""


# ---- VALIDATION ----

if [[ "$MC_DIR" != /* ]]; then
    echo "❌ ERROR: Server directory must be an absolute path (start with /)"
    exit 1
fi

if [[ "$BACKUP_BASE" != /* ]]; then
    echo "❌ ERROR: Backup directory must be an absolute path (start with /)"
    exit 1
fi

if [ ! -d "$MC_DIR" ]; then
    echo "❌ ERROR: Server directory does not exist"
    exit 1
fi

# ---- CREATE DIRECTORIES ----

echo "Creating directories..."
mkdir -p "$HOURLY_DIR" "$DAILY_DIR" "$WEEKLY_DIR" "$LOG_DIR"


# ---- CREATE CONFIG FILE ----

cat > "$CONFIG_FILE" <<EOF
SESSION="$SESSION"
MC_DIR="$MC_DIR"
BACKUP_BASE="$BACKUP_BASE"
HOURLY_DIR="$HOURLY_DIR"
DAILY_DIR="$DAILY_DIR"
WEEKLY_DIR="$WEEKLY_DIR"
LOG_DIR="$LOG_DIR"
EOF

echo "✅ Config created at $CONFIG_FILE"

# ---- DEPENDENCIES ----

echo "Checking dependencies..."

if ! command -v tmux &>/dev/null; then
    echo "Installing tmux..."
    sudo apt install tmux -y
fi

if ! command -v zstd &>/dev/null; then
    echo "Installing zstd..."
    sudo apt install zstd -y
fi

if ! command -v tar &>/dev/null; then
    echo "Installing tar..."
    sudo apt install tar -y
fi

# ---- PERMISSIONS ----

chmod +x hourly_backup.sh daily_backup.sh weekly_backup.sh

# ---- CRON SETUP ----

read -p "Install cron jobs automatically? (y/n) [y]: " INSTALL_CRON
INSTALL_CRON=${INSTALL_CRON:-y}

if [[ "$INSTALL_CRON" =~ ^[Yy]$ ]]; then
    echo "Setting up cron jobs..."

    TMP_CRON=$(mktemp)

    crontab -l 2>/dev/null | grep -v "hourly_backup.sh" | grep -v "daily_backup.sh" | grep -v "weekly_backup.sh" > "$TMP_CRON"

    echo "0 * * * * $SCRIPT_DIR/hourly_backup.sh" >> "$TMP_CRON"
    echo "15 3 * * * $SCRIPT_DIR/daily_backup.sh" >> "$TMP_CRON"
    echo "30 3 * * 1 $SCRIPT_DIR/weekly_backup.sh" >> "$TMP_CRON"

    crontab "$TMP_CRON"
    rm "$TMP_CRON"

    echo "Cron jobs installed."
fi


echo ""
echo "✅ Installation complete!"
echo ""

# ---- TEST BACKUP (OPTIONAL) ----
read -p "Run a test hourly backup now? (y/n) [y]: " RUN_TEST
RUN_TEST=${RUN_TEST:-y}

if [[ "$RUN_TEST" =~ ^[Yy]$ ]]; then
    echo "Running test backup..."
    ./hourly_backup.sh
    echo "Test complete. Check your backup directory."
fi