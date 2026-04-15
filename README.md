# 🧱 Minecraft Backup Manager

A simple, automated backup + restore system for Minecraft servers using `tmux` and `cron`.

Designed to be:

* ⚡ Easy to install
* 🔒 Safe for live servers
* 🧠 Minimal and reliable

---

## ✨ Features

* ⏱️ **Automated hourly, daily, and weekly backups**
* 🔄 **Full server restore support** (complete recovery)
* 🧰 **Interactive installer** (no manual config needed)
* 🧹 **Automatic cleanup** (prevents disk overflow)
* 📦 **ZSTD compression** (fast and efficient)
* 🗑️ **Uninstall script included**
* ⚙️ **Optional cron setup**

---

## 📦 Installation

### 1. Download (Git)

Click:
**Code → Download ZIP**

Or clone:

```bash
git clone https://github.com/j0shh3ss/Minecraft-Backup-Manager.git
cd Minecraft-Backup-Manager
cd scripts
```

---

### 1. Download (No Git)
If you don’t have git installed, you can checkout the latest release directly:

👉 https://github.com/j0shh3ss/Minecraft-Backup-Manager/releases/latest


# Download

```bash
wget https://github.com/j0shh3ss/Minecraft-Backup-Manager/archive/refs/tags/v1.0.4.tar.gz
```

# Extract
```bash
tar -xzf v1.0.4.tar.gz
cd Minecraft-Backup-Manager-1.0.4
cd scripts
pwd
```
Then run:

```bash
chmod +x install.sh
./install.sh
```
---

### 2. Run Installer

```bash
chmod +x install.sh
./install.sh
```

The installer will:

* Ask for your server location - All paths must be absolute (e.g. starts with "/" /mnt/server/minecraft, not home/user/...)
* Configure all scripts automatically
* Optionally install cron jobs
* Optionally run a test backup

---

## 🧪 Manual Backup

Run anytime:

```bash
cd /Minecraft-Backup-Manager-1.0.4
cd scripts
./hourly_backup.sh
```

---

## 🔄 Restore a Backup
First time running (To set permissions)

```bash
cd /Minecraft-Backup-Manager-1.0.4
cd scripts
chmod +x restore.sh
./restore.sh
```

Example usage:

```bash
cd /Minecraft-Backup-Manager-1.0.4
cd scripts
./restore.sh
Tmux session name [Minecraft]: World
Minecraft server root directory (contains world/, versions/, config/, etc.): [/mnt/server/minecraft]: /mnt/server/minecraft
Path to backup file (.tar.zst): /mnt/server/minecraft/backups/hourly/server_hourly-2026-04-14_09.tar.zst
⚠️ WARNING: This will OVERWRITE your current server files!
Continue? (y/n): y
✅ Restore complete!
```

### What this does:

* Pauses world saving safely
* Replaces your server files with the backup
* Restarts saving

⚠️ **This will overwrite your current server files**

---

### 📌 Important

- The directory you enter must be your **server root folder**
- This is the folder that contains files like:
  - `server.jar`
  - `world/`
  - `plugins/` (if applicable)

Example:

Correct:   /mnt/server/minecraft  
Wrong:     /mnt/server/minecraft/world

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

+ Installer assumes a Debian/Ubuntu-based system (`apt`)

---

## 🧠 Notes

* Designed for servers running inside **tmux**
* Uses `save-off` to prevent world corruption
* Backups can use significant disk space depending on retention. Ex: My server directory is 7gb after compression. 24 copies are stored in /hourly. 7 copies are stored in /daily. 4 copies are stored in /weekly. Total = 245GB

---

## ❗ Disclaimer

* Provided as-is
* Test before using in production
* Always verify backups can be restored

---

## 👍 Why This Exists

I wanted a **simple, reliable backup + restore system** for my Minecraft server without plugins or complex tools.

If it helps you too, feel free to use or modify it.
