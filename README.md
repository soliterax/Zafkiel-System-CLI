Overview

ZAFKIEL v3 — Kurumi Tokisaki Linux Power Script is a single-file CLI toolkit for desktop Linux that bundles system maintenance utilities, Flatpak .desktop auto-repair, NTFS repair and USB auto-mounting, optional udev integration, and scheduled automation. All console output and logs are in English and the script preserves a dramatic Zafkiel-themed tone.
Features and What They Do
Feature	Purpose	How it works / Notes
Modular Utilities	Provide quick system tasks	CPU tuning, cache clearing, I/O benchmark, process control, Timeshift restore, SMART reports, mirror optimization, entropy checks. Run from the interactive menu.
Flatpak .desktop Auto-Repair	Restore missing or broken Flatpak desktop entries	Scans Flatpak apps, copies or generates .desktop files into ~/.local/share/applications, updates desktop database.
NTFS Repair	Repair corrupted NTFS partitions	Uses ntfsfix (from ntfs-3g) to fix common NTFS issues for unmounted partitions. Prompts to install ntfs-3g if missing.
USB NTFS Auto-Mount	Auto-mount removable partitions and handle NTFS errors	Detects removable partitions, attempts mount, runs ntfsfix on failure, records mounts to ~/.local/share/zafkiel/usb_mounted.list for safe unmount later.
Udev Integration	Automate mount on device insertion	Optional udev rule + wrapper script call the script in --udev-mount mode to mount newly attached USB partitions as they appear. Requires root to install.
Cron and systemd Timers	Schedule periodic maintenance tasks	Installs cron entries or systemd user timers for Flatpak fixer and the 12-hour automated task cycle.
CLI Launcher and Desktop Entry	Easy invocation and desktop integration	Installs ~/.local/bin/zafkiel and a zafkiel.desktop in the user applications folder for quick access.
Comprehensive Logging	Centralized English logs for auditing and debugging	All actions logged to ~/.local/share/zafkiel/zafkiel.log with levels INFO, WARN, ERR, OK.
Installation

    Save the script

bash

mkdir -p ~/.local/share/zafkiel
# copy the script into ~/.local/share/zafkiel/zafkiel.sh
chmod +x ~/.local/share/zafkiel/zafkiel.sh

    Create CLI launcher

bash

~/.local/share/zafkiel/zafkiel.sh --create-cli

    Optional automation

bash

~/.local/share/zafkiel/zafkiel.sh --install-flatpak-cron
~/.local/share/zafkiel/zafkiel.sh --install-flatpak-timer

    Optional udev auto-mount (requires sudo)

bash

# run the script and choose Install udev auto-mount from the menu
# or:
sudo ~/.local/share/zafkiel/zafkiel.sh
# then select menu option to install udev integration

Usage

    Run interactively

bash

~/.local/share/zafkiel/zafkiel.sh

    Key menu items

        26 — USB NTFS Auto-Mount: scan and mount removable partitions

        27 — USB NTFS Unmount: unmount recorded mounts safely

        28 — Install udev auto-mount: create udev rule and wrapper

        29 — Remove udev auto-mount: uninstall udev integration

        25 — NTFS Disk Fixer: repair unmounted NTFS partitions

    Udev wrapper invocation

bash

~/.local/share/zafkiel/zafkiel.sh --udev-mount /dev/sdX1

    View logs

bash

less ~/.local/share/zafkiel/zafkiel.log

Maintenance and Troubleshooting

Requirements

    Linux (systemd recommended), sudo for privileged operations.

    Recommended packages: ntfs-3g, flatpak, cpupower, fio, smartmontools, reflector. Script uses pacman for automated installs by default.

Common fixes

    Mount fails: check filesystem type lsblk -f /dev/sdX1. If NTFS, ensure ntfs-3g is installed.

    Udev rule not triggering: verify /etc/udev/rules.d/99-zafkiel-usb-mount.rules exists and run:

bash

sudo udevadm control --reload-rules && sudo udevadm trigger

    Permissions: udev installation and mount/umount require root; the script will request sudo when needed.

Uninstall steps

    Remove udev integration

bash

sudo rm -f /etc/udev/rules.d/99-zafkiel-usb-mount.rules
rm -f ~/.local/share/zafkiel/udev-usb-mount-wrapper.sh
sudo udevadm control --reload-rules

    Unmount and clean recorded mounts

bash

while IFS='|' read -r dev mp; do sudo umount "$mp" || true; rmdir --ignore-fail-on-non-empty "$mp" 2>/dev/null || true; done < ~/.local/share/zafkiel/usb_mounted.list
rm -f ~/.local/share/zafkiel/usb_mounted.list

    Remove launcher and data

bash

rm -f ~/.local/bin/zafkiel
rm -rf ~/.local/share/zafkiel
rm -f ~/.local/share/applications/zafkiel.desktop


Menu Summary
Menu    Purpose Primary action  Prerequisite
1 Aleph CPU performance tuning  enable cpupower service; set governor to performance    cpupower installed; sudo
2 Beth  Quick system inspection run htop or top snapshot    htop optional
3 Gimel Free pagecache and dentries sync then echo 3 > /proc/sys/vm/drop_caches sudo
4 Dalet Change working directory interactively  prompt for directory and cd into it none
5 He    Run background command  prompt for command and run with nohup   none
6 Vav   I/O benchmark   run fio test or fallback dd fio recommended
7 Zayin Freeze a process    kill -STOP  sudo
8 Het   Timeshift restore helper    list and optionally run timeshift --restore timeshift
9 Tet   Network trace   tracepath or fallback ping  tracepath optional
10 Yud  Force logrotate logrotate -f /etc/logrotate.conf    sudo
11 YudAleph Load prediction show uptime and top CPU processes   none
12 YudBet   Toggle amd_pstate   append amd_pstate=active to loader entries  sudo; backup created
13 RyzenAdj Apply Ryzen power profile   run ryzenadj with configured limits ryzenadj; sudo
14 NVIDIA Offload   Run command with NVIDIA offload env run command with __NV_PRIME_RENDER_OFFLOAD env  NVIDIA drivers configured
15 Steam CombatData Move Steam CombatData to user folder    move folder and create symlink  Steam compatdata path exists
16 WinBoat Doctor   Check KVM presence  check lsmod and /dev/kvm    none
17 Mirror Optimize  Update pacman mirrors   run reflector to update mirrorlist  reflector; sudo
18 Disk SMART   Save SMART report   run smartctl -a and save to log smartctl; sudo
19 Battery Entropy  Show battery and entropy    run upower and show /proc/sys/kernel/random/entropy_avail   upower optional
20 Network Speedtest    Run speedtest   run speedtest-cli   speedtest-cli
21 Flatpak Fixer    Repair Flatpak .desktop files   scan flatpak list, copy/generate .desktop   flatpak
22 Install Flatpak Cron Cron for Flatpak fixer  create cron entry to run fixer every 12h    crontab
23 Install Flatpak Timer    systemd user timer for fixer    create systemd user service and timer   systemd user session
24 Create CLI Launcher  Install zafkiel command symlink script to ~/.local/bin and create .desktop  none
25 NTFS Disk Fixer  Repair unmounted NTFS partitions    run ntfsfix on unmounted NTFS devices   ntfs-3g/ntfsfix; sudo
26 USB NTFS Auto-Mount  Scan and mount removable partitions detect removable partitions, mount, run ntfsfix on failure, record mounts   sudo; ntfsfix recommended
27 USB NTFS Unmount Unmount recorded mounts read usb_mounted.list, umount and cleanup mountpoints   sudo
28 Install udev auto-mount  Auto-run mount on device add    install udev rule and wrapper to call script on add sudo to write udev rule
29 Remove udev auto-mount   Remove udev integration remove udev rule and wrapper, reload rules  sudo
Core Menu Items Explained
Aleph CPU Boost

What it does: Enables cpupower service and sets CPU governor to performance.
Commands run: systemctl enable --now cpupower.service, cpupower frequency-set -g performance.
Why use it: For short-term maximum performance (gaming, heavy compute).
Caveat: Higher power draw and heat; use only when cooling and power budget allow.
Beth System Inspect

What it does: Opens htop if available; otherwise prints a top snapshot.
Commands run: htop or top -b -n1 | head -n20.
Why use it: Quick interactive view of processes and resource usage.
Gimel Free Cache

What it does: Frees pagecache, dentries and inodes to reclaim memory.
Commands run: sync then echo 3 > /proc/sys/vm/drop_caches.
Caveat: This is safe but may evict useful cached data; only use when necessary.
Dalet Directory Teleport

What it does: Prompts for a directory and opens a shell in that directory.
Why use it: Quick navigation and interactive session in a target folder.
He Process Clone

What it does: Runs a user-provided command in background with nohup.
Commands run: nohup bash -lc "<cmd>" &.
Why use it: Start long-running tasks detached from terminal.
Vav I/O Benchmark

What it does: Runs fio I/O benchmark; falls back to dd if fio missing.
Outputs: Writes temporary test file under ~/.local/share/zafkiel/io and prints results.
Caveat: dd is a crude test; fio gives more accurate metrics.
Zayin Freeze PID

What it does: Pauses a process using kill -STOP.
Why use it: Temporarily suspend runaway or heavy processes for inspection.
Undo: kill -CONT <PID> to resume.
Het Timeshift Restore

What it does: Lists Timeshift snapshots and optionally runs a restore.
Prerequisite: timeshift installed and configured.
Caveat: Restores are system-impacting; script prompts for confirmation.
Tet Network Trace

What it does: Runs tracepath to a target host or falls back to ping.
Why use it: Diagnose routing and latency issues.
Yud Logrotate

What it does: Forces logrotate to run immediately.
Commands run: sudo logrotate -f /etc/logrotate.conf.
Why use it: Rotate logs manually when disk space is low.
Extra Powers Explained
RyzenAdj Profile

What it does: Applies power limits and temperature target via ryzenadj.
Commands run: ryzenadj --stapm-limit ... --tctl-temp ....
Caveat: Requires ryzenadj and careful tuning; misuse can destabilize system.
NVIDIA Offload

What it does: Runs a command with environment variables for NVIDIA PRIME offload.
Use case: Run GPU-accelerated apps on hybrid systems.
Steam CombatData Fix

What it does: Moves Steam compatibility data folder to ~/.local/share/zafkiel and symlinks it back.
Why: Free up space on the original drive or fix permission issues.
WinBoat Doctor

What it does: Checks kernel modules for virtualization and presence of /dev/kvm.
Why: Quick VM readiness check.
Mirror Optimize

What it does: Runs reflector to refresh pacman mirrorlist sorted by speed.
Caveat: Only on Arch-like systems; requires reflector and sudo.
Disk SMART Report

What it does: Runs smartctl -a and saves output to ~/.local/share/zafkiel.
Why: Health check for disks; useful before failures.
Battery Entropy and Network Speedtest

What they do: Show battery info and system entropy; run speedtest-cli for network throughput.
Flatpak and Automation Explained
Flatpak .desktop Fixer

What it does: Scans installed Flatpak apps, copies exported .desktop files into ~/.local/share/applications, or generates minimal .desktop entries when missing.
Commands run: flatpak list, flatpak info, copy/generate .desktop files, update-desktop-database if available.
Why: Fix broken or missing application entries in desktop menus.
Install Flatpak Cron and Timer

What they do:

    Cron: writes a small wrapper and adds a crontab entry to run the fixer every 12 hours.

    Systemd user timer: creates a user service and timer to run the fixer every 12 hours.
    Notes: Choose one or both depending on preference; systemd user timers require a running user systemd session.

Create CLI Launcher

What it does: Symlinks the script to ~/.local/bin/zafkiel and creates a zafkiel.desktop entry in the user applications folder.
Why: Easy invocation and desktop integration.
NTFS and USB Auto-Mount Explained
NTFS Disk Fixer

What it does: Finds unmounted NTFS partitions and runs ntfsfix on them.
Commands run: lsblk to detect NTFS partitions, ntfsfix /dev/sdX.
Prerequisite: ntfs-3g (provides ntfsfix) and sudo.
Caveat: ntfsfix is not a full Windows chkdsk replacement; it fixes common issues to allow mounting.
USB NTFS Auto-Mount

What it does: Detects removable partitions (via lsblk), attempts to mount each to /mnt/<device>. If mount fails and filesystem is NTFS, runs ntfsfix and retries. Records successful mounts in ~/.local/share/zafkiel/usb_mounted.list.
Why: Make plugging a USB drive a one-step operation for users who want quick access.
Safety: Mounts are recorded so they can be unmounted cleanly later. Mounting uses sudo and may prompt for password.
USB NTFS Unmount

What it does: Reads usb_mounted.list, unmounts each recorded mountpoint, removes the record, and removes empty mount directories.
Why: Safe cleanup to avoid leaving stale mounts or dangling directories.
Install udev auto-mount

What it does: Installs a udev rule and a small wrapper script that calls the main script in --udev-mount /dev/<node> mode when a USB partition is added.
Why: Fully automatic behavior on device insertion.
Caveat: udev rules run as root and must not block; the wrapper runs the script in background. Installing/removing the rule requires sudo.
Remove udev auto-mount

What it does: Removes the udev rule and wrapper and reloads udev rules.
Why: Revert to manual control or uninstall the feature.
Installer, Config and Safety Notes
Installer Menu Option

What it does: Offers to install recommended packages (cpupower, rsync, coreutils, util-linux) and optionally set up Flatpak fixer cron/timer and CLI launcher.
Why: Convenience to bootstrap dependencies on Arch-like systems.
Save Configuration

What it does: Writes current configurable variables (e.g., RYZEN_TDP_W, RYZEN_TCTL_MAX, STEAM_COMPATDATA, LOADER_DIR) to ~/.local/share/zafkiel/config.conf.
Why: Persist user preferences across runs.
Logging

What it does: All actions and messages are appended to ~/.local/share/zafkiel/zafkiel.log with timestamps and levels (INFO, WARN, ERR, OK).
Why: Audit trail and troubleshooting. Check this file when something behaves unexpectedly.
Safety and Undo

    Privileged actions (mount, umount, ntfsfix, systemctl, writing udev rules) requiresudo. The script prompts forsudo` when needed.

    Backups: When modifying system files (e.g., loader entries for amd_pstate), the script creates a timestamped backup.

    Undo: Use the menu options to remove udev integration, unmount recorded mounts, or restore backups created in the script’s operations. Manual undo steps are documented in the README and logged.

Contributing and License

    Contributions welcome: open focused pull requests and keep commits small. Preserve English log messages and the Zafkiel dramatic tone where appropriate. For major changes, open an issue first.

    License: GNU GENERAL PUBLIC LICENSE 2

Tip: After installing udev integration, plug in a USB device and monitor ~/.local/share/zafkiel/zafkiel.log to confirm automatic mount and any ntfsfix activity.