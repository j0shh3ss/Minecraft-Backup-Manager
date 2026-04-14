#!/bin/bash

set -euo pipefail

echo "==== Minecraft Backup Script Installer ===="

# ---- USER INPUT ----

read -p "Tmux session name [Minecraft]: " SESSION
SESSION=${SESSION:-Minecraft}

read -p "Minecraft server directory (contains world) [/mnt/server/minecraft/world]: " MC_DIR
MC_DIR=${MC_DIR:-/mnt/server/minecraft/world}

read -p "Backup base directory [/mnt/server/minecraft/backups]: " BACKUP_BASE
BACKUP_BASE=${BACKUP_BASE:-/mnt/server/minecraft/backups}

# Derived paths
HOURLY_DIR="$BACKUP_BASE/hourly"
DAILY_DIR="$BACKUP_BASE/daily"
WEEKLY_DIR="$BACKUP_BASE/weekly"
LOG_DIR="$BACKUP_BASE/logs"

echo ""
echo "Using configuration:"
echo "SESSION=$SESSION"
echo "MC_DIR=$MC_DIR"
echo "BACKUP_BASE=$BACKUP_BASE"
echo ""

# ---- CREATE DIRECTORIES ----

echo "Creating directories..."
mkdir -p "$HOURLY_DIR" "$DAILY_DIR" "$WEEKLY_DIR" "$LOG_DIR"

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

# ---- UPDATE SCRIPTS ----

echo "Configuring scripts..."

# Hourly
sed -i "s|^SESSION=.*|SESSION=\"$SESSION\"|" hourly_backup.sh
sed -i "s|^MC_DIR=.*|MC_DIR=\"$MC_DIR\"|" hourly_backup.sh
sed -i "s|^BACKUP_DIR=.*|BACKUP_DIR=\"$HOURLY_DIR\"|" hourly_backup.sh
sed -i "s|^LOG_DIR=.*|LOG_DIR=\"$LOG_DIR\"|" hourly_backup.sh

# Daily
sed -i "s|^SOURCE_DIR=.*|SOURCE_DIR=\"$HOURLY_DIR\"|" daily_backup.sh
sed -i "s|^DEST_DIR=.*|DEST_DIR=\"$DAILY_DIR\"|" daily_backup.sh
sed -i "s|^LOG_DIR=.*|LOG_DIR=\"$LOG_DIR\"|" daily_backup.sh

# Weekly
sed -i "s|^SOURCE_DIR=.*|SOURCE_DIR=\"$DAILY_DIR\"|" weekly_backup.sh
sed -i "s|^DEST_DIR=.*|DEST_DIR=\"$WEEKLY_DIR\"|" weekly_backup.sh
sed -i "s|^LOG_DIR=.*|LOG_DIR=\"$LOG_DIR\"|" weekly_backup.sh

# ---- PERMISSIONS ----

chmod +x hourly_backup.sh daily_backup.sh weekly_backup.sh

# ---- CRON SETUP ----

read -p "Install cron jobs automatically? (y/n) [y]: " INSTALL_CRON
INSTALL_CRON=${INSTALL_CRON:-y}

if [[ "$INSTALL_CRON" =~ ^[Yy]$ ]]; then
    echo "Setting up cron jobs..."

    SCRIPT_DIR=$(pwd)

    (crontab -l 2>/dev/null; echo "0 * * * * $SCRIPT_DIR/hourly_backup.sh") | crontab -
    (crontab -l 2>/dev/null; echo "15 3 * * * $SCRIPT_DIR/daily_backup.sh") | crontab -
    (crontab -l 2>/dev/null; echo "30 3 * * 1 $SCRIPT_DIR/weekly_backup.sh") | crontab -

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