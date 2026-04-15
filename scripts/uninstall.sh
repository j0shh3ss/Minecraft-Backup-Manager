#!/bin/bash

set -euo pipefail

echo "==== Minecraft Backup Script Uninstaller ===="
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/backup.conf"

if [ ! -f "$CONFIG" ]; then
    echo "❌ Missing config file: $CONFIG"
    echo "Run install.sh first."
    exit 1
fi

source "$CONFIG"

# ---- REMOVE CRON JOBS ----

read -p "Remove cron jobs? (y/n) [y]: " REMOVE_CRON
REMOVE_CRON=${REMOVE_CRON:-y}

if [[ "$REMOVE_CRON" =~ ^[Yy]$ ]]; then
    echo "Removing cron jobs..."

    crontab -l 2>/dev/null | grep -v "$SCRIPT_DIR/hourly_backup.sh" \
    | grep -v "$SCRIPT_DIR/daily_backup.sh" \
    | grep -v "$SCRIPT_DIR/weekly_backup.sh" | crontab -

    echo "Cron jobs removed."
fi

# ---- REMOVE BACKUPS ----

read -p "Delete all backup files? (y/n) [n]: " DELETE_BACKUPS
DELETE_BACKUPS=${DELETE_BACKUPS:-n}

if [[ "$DELETE_BACKUPS" =~ ^[Yy]$ ]]; then
    read -p "Enter backup base directory to delete: " BACKUP_BASE

    if [ -d "$BACKUP_BASE" ]; then
        echo "Deleting backups in $BACKUP_BASE..."
        rm -rf "$BACKUP_BASE"
        echo "Backups deleted."
    else
        echo "Directory not found, skipping."
    fi
fi

# ---- REMOVE LOG FILE ----

read -p "Remove log file (/var/log/mc-backup-hourly.log)? (y/n) [n]: " REMOVE_LOG
REMOVE_LOG=${REMOVE_LOG:-n}

if [[ "$REMOVE_LOG" =~ ^[Yy]$ ]]; then
    sudo rm -f /var/log/mc-backup-hourly.log || true
    echo "Log file removed."
fi

# ---- REMOVE SCRIPT PERMISSIONS (OPTIONAL) ----

read -p "Remove execute permissions from scripts? (y/n) [n]: " REMOVE_PERMS
REMOVE_PERMS=${REMOVE_PERMS:-n}

if [[ "$REMOVE_PERMS" =~ ^[Yy]$ ]]; then
    chmod -x hourly_backup.sh daily_backup.sh weekly_backup.sh || true
    echo "Permissions removed."
fi

echo ""
echo "✅ Uninstall complete."
echo "Note: Your Minecraft server files were NOT touched."