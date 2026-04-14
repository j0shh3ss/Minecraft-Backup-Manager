# Server-Backup-Scripts

Simple, automated backup scripts designed for Minecraft servers using `tmux` and `cron`.

These scripts create **hourly, daily, and weekly backups** with automatic cleanup to manage disk usage.

---

## ⚙️ Requirements

These scripts assume:

* You are running your server inside a **tmux session**
* You can schedule jobs using **crontab**
* You have enough disk space for backups

  * Example: a 7GB world ≈ ~245GB with full retention

Dependencies:

* `tmux`
* `tar`
* `zstd`

---

## 📦 What It Does

* **Hourly script**

  * Saves the world safely (`save-off`)
  * Copies files to a temp directory
  * Compresses using `zstd`
  * Cleans up old hourly backups (~25 hours by default)

* **Daily script**

  * Copies the latest hourly backup
  * Keeps 7 days of backups

* **Weekly script**

  * Copies the latest hourly backup
  * Keeps 4 weeks of backups

---

## 🛠️ Setup

### 1. Edit Variables

You **must** update these values in `hourly_backup.sh`:

* `SESSION` → your tmux session name
* `MC_DIR` → your server directory
* `BACKUP_DIR` → where backups are stored

⚠️ Important:

* Do NOT include a trailing slash in `MC_DIR`
* Make sure all directories exist or can be created

---

### 2. Schedule with Cron

Example:
* Note: I put my scripts under SUDO but this does not follow least privlege.

edit crontab and add scripts at the end of the file with
sudo crontab -e

```bash
# Hourly backup
0 * * * * /path/to/hourly_backup.sh

# Daily backup
15 3 * * * /path/to/daily_backup.sh

# Weekly backup
30 3 * * 1 /path/to/weekly_backup.sh
```

This example schedules:
- Hourly backups at the start of every hour
- Daily backups at 3:15 AM
- Weekly backups every Monday at 3:30 AM

Cron format:
1 2 3 4 5
* * * * *

1: Day of week (0-7, Sunday = 0 or 7)
2: Month
3: Day of month
4: Hour
5: Minute

---

## 🧠 Notes

* Backups are compressed using `zstd` for speed and efficiency
* A temporary directory is used to prevent corruption during copy
* The script automatically re-enables saving if something fails

---

## ⚠️ Disclaimer

* These scripts are provided as-is
* Test them before relying on them in production
* Make sure your backups are actually restorable

---

## 👍 Why I Made This

I wanted a **simple, reliable backup system** for my Minecraft server without needing complex tools or plugins.

Feel free to modify and use it for your own setup.
