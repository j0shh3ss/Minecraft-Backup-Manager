# 🧱 Minecraft Backup Manager

A simple, automated backup + restore system for Minecraft servers using `tmux` and `cron`.

Designed to be:

* ⚡ Easy to install
* 🔒 Safe for live servers
* 🧠 Minimal and reliable

---

## ✨ Features

* ⏱️ **Automated hourly, daily, and weekly backups**
* 🔄 **Full restore support** (recover your server instantly)
* 🧰 **Interactive installer** (no manual config needed)
* 🧹 **Automatic cleanup** (prevents disk overflow)
* 📦 **ZSTD compression** (fast and efficient)
* 🗑️ **Uninstall script included**
* ⚙️ **Optional cron setup**

---

## 📦 Installation

### 1. Download

Click:
**Code → Download ZIP**

Or clone:

```bash
git clone https://github.com/j0shh3ss/Minecraft-Backup-Manager.git
cd Minecraft-Backup-Manager
```

---

### 2. Run Installer

```bash
chmod +x install.sh
./install.sh
```

The installer will:

* Ask for your server location
* Configure all scripts automatically
* Optionally install cron jobs
* Optionally run a test backup

---

## 🧪 Manual Backup

Run anytime:

```bash
./hourly_backup.sh
```

---

## 🔄 Restore a Backup

```bash
./restore.sh <backup_file.tar.zst>
```

Example:

```bash
./restore.sh world_hourly-2026-04-14_15.tar.zst
```

### What this does:

* Pauses world saving safely
* Replaces your server files with the backup
* Restarts saving

⚠️ **This will overwrite your current server files**

---

## ⏱️ Cron Jobs

If enabled, the installer schedules:

* Hourly → every hour
* Daily → 3:15 AM
* Weekly → Monday 3:30 AM

Edit anytime with:

```bash
crontab -e
```

---

## 📁 Folder Structure

```bash
backups/
├── hourly/
├── daily/
├── weekly/
└── logs/
```

---

## 🧹 Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Options:

* Remove cron jobs
* Delete backups
* Remove logs

---

## ⚙️ Requirements

* Linux system
* `tmux`
* `tar`
* `zstd`
* `cron`

Installer will attempt to install missing dependencies.

---

## 🧠 Notes

* Designed for servers running inside **tmux**
* Uses `save-off` to prevent world corruption
* Backups can use significant disk space depending on retention

---

## ❗ Disclaimer

* Provided as-is
* Test before using in production
* Always verify backups can be restored

---

## 👍 Why This Exists

I wanted a **simple, reliable backup + restore system** for my Minecraft server without plugins or complex tools.

If it helps you too, feel free to use or modify it.
