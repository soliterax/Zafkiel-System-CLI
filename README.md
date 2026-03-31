# ZAFKIEL System CLI

**Single-file CLI for system maintenance, Flatpak .desktop repair, NTFS recovery and USB auto-mount.**

---

## Overview
ZAFKIEL v3 — Kurumi Tokisaki Linux Power Script is a single-file CLI toolkit for desktop Linux that bundles system maintenance utilities, Flatpak .desktop auto-repair, NTFS repair and USB auto-mounting, optional udev integration, and scheduled automation.
All console output and logs are in English and the script preserves a dramatic Zafkiel-themed tone.

ZAFKIEL System CLI is designed for power users and system administrators who want a compact, scriptable helper for desktop Linux maintenance and USB/NTFS handling.

---

## Features
| **Feature** | **What it does** | **Notes** |
|---|---|---|
| **Modular Utilities** | CPU tuning, cache clearing, I/O benchmark, process control, Timeshift restore, SMART reports, mirror optimization, entropy checks. | Run from the interactive menu. |
| **Flatpak .desktop Auto-Repair** | Restore missing or broken Flatpak desktop entries. | Copies or generates `.desktop` files into `~/.local/share/applications`. |
| **NTFS Repair** | Repair corrupted NTFS partitions. | Uses `ntfsfix` (from `ntfs-3g`); prompts to install if missing. |
| **USB NTFS Auto-Mount** | Auto-mount removable partitions and handle NTFS errors. | Records mounts to `~/.local/share/zafkiel/usb_mounted.list` for safe unmount. |
| **Udev Integration** | Automate mount on device insertion. | Optional udev rule + wrapper; requires `sudo` to install. |
| **Cron & systemd Timers** | Schedule periodic maintenance tasks. | Installs cron entries or systemd user timers for automation. |
| **CLI Launcher & Desktop Entry** | Easy invocation and desktop integration. | Installs `~/.local/bin/zafkiel` and a `.desktop` file. |
| **Comprehensive Logging** | Centralized English logs for auditing and debugging. | Logs to `~/.local/share/zafkiel/zafkiel.log` with levels INFO/WARN/ERR/OK. |

---

## Installation
1. Save the script:
```bash
mkdir -p ~/.local/share/zafkiel
# copy the script into ~/.local/share/zafkiel/zafkiel.sh
chmod +x ~/.local/share/zafkiel/zafkiel.sh
```
2. Create CLI launcher:

```bash

~/.local/share/zafkiel/zafkiel.sh --create-cli
```
3. Optional automation:

```bash

~/.local/share/zafkiel/zafkiel.sh --install-flatpak-cron
~/.local/share/zafkiel/zafkiel.sh --install-flatpak-timer
```
4. Optional udev auto-mount (requires sudo):

```bash

sudo ~/.local/share/zafkiel/zafkiel.sh
# then choose "Install udev auto-mount" from the menu
```
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


##Menu Summary
| **Menu** | **Purpose** | **Primary action** | **Prerequisite** |
|---|---|---|---|
|**1 Aleph** | CPU performance tuning | enable cpupower service; set governor to performance | cpupower installed; sudo
|**2 Beth** | Quick system inspection | run htop or top snapshot | htop optional
|**3 Gimel** | Free pagecache and dentries | sync then echo 3 > /proc/sys/vm/drop_caches | sudo
|**4 Dalet** | Change working directory interactively | prompt for directory and cd into it | none
|**5 He** | Run background command | prompt for command and run with nohup | none
|**6 Vav** | I/O benchmark | run fio test or fallback dd | fio recommended
|**7 Zayin** | Freeze a process | kill -STOP | sudo
|**8 Het** | Timeshift restore helper | list and optionally run timeshift --restore | timeshift
|**9 Tet** | Network trace | tracepath or fallback ping | tracepath optional
|**10 Yud** | Force logrotate | logrotate -f /etc/logrotate.conf | sudo
|**11 YudAleph** | Load prediction | show uptime and top CPU processes | none
|**12 YudBet** | Toggle amd_pstate | append amd_pstate=active to loader entries | sudo; backup created
|**13 RyzenAdj** | Apply Ryzen power profile | run ryzenadj with configured limits | ryzenadj; sudo
|**14 NVIDIA Offload** | Run command with NVIDIA offload env | run command with __NV_PRIME_RENDER_OFFLOAD env | NVIDIA drivers configured
|**15 Steam CombatData** | Move Steam CombatData to user folder | move folder and create symlink | Steam compatdata path exists
|**16 WinBoat Doctor** | Check KVM presence | check lsmod and /dev/kvm | none
|**17 Mirror Optimize** | Update pacman mirrors | run reflector to update mirrorlist | reflector; sudo
|**18 Disk SMART** | Save SMART report | run smartctl -a and save to log | smartctl; sudo
|**19 Battery Entropy** | Show battery and entropy | run upower and show /proc/sys/kernel/random/entropy_avail | upower optional
|**20 Network Speedtest** | Run speedtest | run speedtest-cli | speedtest-cli
|**21 Flatpak Fixer** | Repair Flatpak .desktop files | scan flatpak list, copy/generate .desktop | flatpak
|**22 Install Flatpak Cron** | Cron for Flatpak fixer | create cron entry to run fixer every 12h | crontab
|**23 Install Flatpak Timer** | systemd user timer for fixer | create systemd user service and timer | systemd user session
|**24 Create CLI Launcher** | Install zafkiel command | symlink script to ~/.local/bin and create .desktop | none
|**25 NTFS Disk Fixer** | Repair unmounted NTFS partitions | run ntfsfix on unmounted NTFS devices | ntfs-3g/ntfsfix; sudo
|**26 USB NTFS Auto-Mount** | Scan and mount removable partitions | detect removable partitions, mount, run ntfsfix on failure, record mounts | sudo; ntfsfix recommended
|**27 USB NTFS Unmount** | Unmount recorded mounts | read usb_mounted.list, umount and cleanup mountpoints | sudo
|**28 Install udev auto-mount** | Auto-run mount on device add | install udev rule and wrapper to call script on add | sudo to write udev rule
|**29 Remove udev auto-mount** | Remove udev integration | remove udev rule and wrapper, reload rules | sudo
## Core Menu Items Explained

### Aleph — CPU Boost
**Q: What does it do?**  
Enables `cpupower` service and sets CPU governor to `performance`.  

**Q: Commands run:**  
`systemctl enable --now cpupower.service`  
`cpupower frequency-set -g performance`  

**Q: Why use it?**  
For short-term maximum performance (gaming, heavy compute).  

**Q: Caveat:**  
Higher power draw and heat; use only when cooling and power budget allow.

---

### Beth — System Inspect
**Q: What does it do?**  
Opens `htop` if available; otherwise prints a `top` snapshot.  

**Q: Commands run:**  
`htop` or `top -b -n1 | head -n20`  

**Q: Why use it?**  
Quick interactive view of processes and resource usage.

---

### Gimel — Free Cache
**Q: What does it do?**  
Frees pagecache, dentries and inodes to reclaim memory.  

**Q: Commands run:**  
`sync` then `echo 3 > /proc/sys/vm/drop_caches`  

**Q: Caveat:**  
This is safe but may evict useful cached data; only use when necessary.

---

### Dalet — Directory Teleport
**Q: What does it do?**  
Prompts for a directory and opens a shell in that directory.  

**Q: Why use it?**  
Quick navigation and interactive session in a target folder.

---

### He — Process Clone
**Q: What does it do?**  
Runs a user-provided command in background with `nohup`.  

**Q: Commands run:**  
`nohup bash -lc "<cmd>" &`  

**Q: Why use it?**  
Start long-running tasks detached from terminal.

---

### Vav — I/O Benchmark
**Q: What does it do?**  
Runs `fio` I/O benchmark; falls back to `dd` if `fio` is missing.  

**Q: Outputs:**  
Writes temporary test file under `~/.local/share/zafkiel/io` and prints results.  

**Q: Caveat:**  
`dd` is a crude test; `fio` gives more accurate metrics.

---

### Zayin — Freeze PID
**Q: What does it do?**  
Pauses a process using `kill -STOP`.  

**Q: Why use it?**  
Temporarily suspend runaway or heavy processes for inspection.  

**Q: Undo:**  
`kill -CONT <PID>` to resume.

---

### Het — Timeshift Restore
**Q: What does it do?**  
Lists Timeshift snapshots and optionally runs a restore.  

**Q: Prerequisite:**  
`timeshift` installed and configured.  

**Q: Caveat:**  
Restores are system-impacting; script prompts for confirmation.

---

### Tet — Network Trace
**Q: What does it do?**  
Runs `tracepath` to a target host or falls back to `ping`.  

**Q: Why use it?**  
Diagnose routing and latency issues.

---

### Yud — Logrotate
**Q: What does it do?**  
Forces `logrotate` to run immediately.  

**Q: Commands run:**  
`sudo logrotate -f /etc/logrotate.conf`  

**Q: Why use it?**  
Rotate logs manually when disk space is low.

---

## Extra Powers Explained

### RyzenAdj Profile
**Q: What does it do?**  
Applies power limits and temperature target via `ryzenadj`.  

**Q: Commands run:**  
`ryzenadj --stapm-limit ... --tctl-temp ...`  

**Q: Caveat:**  
Requires `ryzenadj` and careful tuning; misuse can destabilize system.

---

### NVIDIA Offload
**Q: What does it do?**  
Runs a command with environment variables for NVIDIA PRIME offload.  

**Q: Use case:**  
Run GPU-accelerated apps on hybrid systems.

---

### Steam CombatData Fix
**Q: What does it do?**  
Moves Steam compatibility data folder to `~/.local/share/zafkiel` and symlinks it back.  

**Q: Why:**  
Free up space on the original drive or fix permission issues.

---

### WinBoat Doctor
**Q: What does it do?**  
Checks kernel modules for virtualization and presence of `/dev/kvm`.  

**Q: Why use it?**  
Quick VM readiness check.

---

### Mirror Optimize
**Q: What does it do?**  
Runs `reflector` to refresh pacman mirrorlist sorted by speed.  

**Q: Caveat:**  
Only on Arch-like systems; requires `reflector` and `sudo`.

---

### Disk SMART Report
**Q: What does it do?**  
Runs `smartctl -a` and saves output to `~/.local/share/zafkiel`.  

**Q: Why use it?**  
Health check for disks; useful before failures.

---

### Battery Entropy and Network Speedtest
**Q: What do they do?**  
Show battery info and system entropy; run `speedtest-cli` for network throughput.

---

## Flatpak and Automation Explained

### Flatpak .desktop Fixer
**Q: What does it do?**  
Scans installed Flatpak apps, copies exported `.desktop` files into `~/.local/share/applications`, or generates minimal `.desktop` entries when missing.  

**Q: Commands run:**  
`flatpak list`, `flatpak info`, copy/generate `.desktop` files, `update-desktop-database` if available.  

**Q: Why:**  
Fix broken or missing application entries in desktop menus.

---

### Install Flatpak Cron and Timer
**Q: What do they do?**  
- **Cron:** writes a small wrapper and adds a crontab entry to run the fixer every 12 hours.  
- **Systemd user timer:** creates a user service and timer to run the fixer every 12 hours.  

**Q: Notes:**  
Choose one or both depending on preference; systemd user timers require a running user systemd session.

---

### Create CLI Launcher
**Q: What does it do?**  
Symlinks the script to `~/.local/bin/zafkiel` and creates a `zafkiel.desktop` entry in the user applications folder.  

**Q: Why:**  
Easy invocation and desktop integration.

---

## NTFS and USB Auto-Mount Explained

### NTFS Disk Fixer
**Q: What does it do?**  
Finds unmounted NTFS partitions and runs `ntfsfix` on them.  

**Q: Commands run:**  
`lsblk` to detect NTFS partitions, `ntfsfix /dev/sdX`.  

**Q: Prerequisite:**  
`ntfs-3g` (provides `ntfsfix`) and `sudo`.  

**Q: Caveat:**  
`ntfsfix` is not a full Windows `chkdsk` replacement; it fixes common issues to allow mounting.

---

### USB NTFS Auto-Mount
**Q: What does it do?**  
Detects removable partitions (via `lsblk`), attempts to mount each to `/mnt/<device>`. If mount fails and filesystem is NTFS, runs `ntfsfix` and retries. Records successful mounts in `~/.local/share/zafkiel/usb_mounted.list`.  

**Q: Why:**  
Make plugging a USB drive a one-step operation for quick access.

**Q: Safety:**  
Mounts are recorded so they can be unmounted cleanly later. Mounting uses `sudo` and may prompt for password.

---

### USB NTFS Unmount
**Q: What does it do?**  
Reads `usb_mounted.list`, unmounts each recorded mountpoint, removes the record, and removes empty mount directories.  

**Q: Why:**  
Safe cleanup to avoid leaving stale mounts or dangling directories.

---

### Install udev auto-mount
**Q: What does it do?**  
Installs a udev rule and a small wrapper script that calls the main script in `--udev-mount /dev/<node>` mode when a USB partition is added.  

**Q: Why:**  
Fully automatic behavior on device insertion.

**Q: Caveat:**  
Udev rules run as root and must not block; the wrapper runs the script in background. Installing/removing the rule requires `sudo`.

---

### Remove udev auto-mount
**Q: What does it do?**  
Removes the udev rule and wrapper and reloads udev rules.  

**Q: Why:**  
Revert to manual control or uninstall the feature.

---

## Installer, Config and Safety Notes

### Installer Menu Option
**Q: What does it do?**  
Offers to install recommended packages (`cpupower`, `rsync`, `coreutils`, `util-linux`) and optionally set up Flatpak fixer cron/timer and CLI launcher.  

**Q: Why:**  
Convenience to bootstrap dependencies on Arch-like systems.

---

### Save Configuration
**Q: What does it do?**  
Writes current configurable variables (e.g., `RYZEN_TDP_W`, `RYZEN_TCTL_MAX`, `STEAM_COMPATDATA`, `LOADER_DIR`) to `~/.local/share/zafkiel/config.conf`.  

**Q: Why:**  
Persist user preferences across runs.

---

### Logging
**Q: What does it do?**  
All actions and messages are appended to `~/.local/share/zafkiel/zafkiel.log` with timestamps and levels (`INFO`, `WARN`, `ERR`, `OK`).  

**Q: Why:**  
Audit trail and troubleshooting. Check this file when something behaves unexpectedly.

---

### Safety and Undo
**Q: Privileged actions:**  
Mount, umount, `ntfsfix`, `systemctl`, writing udev rules require `sudo`. The script prompts for `sudo` when needed.

**Q: Backups:**  
When modifying system files (e.g., loader entries for `amd_pstate`), the script creates a timestamped backup.

**Q: Undo:**  
Use the menu options to remove udev integration, unmount recorded mounts, or restore backups created by the script. Manual undo steps are documented in the README and logged.

---

## Quick Commands (examples)

- **Force logrotate:**  
  `sudo logrotate -f /etc/logrotate.conf`

- **Free caches:**  
  `sync && echo 3 | sudo tee /proc/sys/vm/drop_caches`

- **Run fio test (example):**  
  `fio --name=randread --filename=~/.local/share/zafkiel/io/testfile --rw=randread --bs=4k --size=1G --numjobs=1 --time_based --runtime=30`

- **Check NTFS partitions:**  
  `lsblk -f | grep ntfs`

- **Run ntfsfix:**  
  `sudo ntfsfix /dev/sdX1`

---

## Notes
- Many features assume recommended packages are installed; the installer can offer to install them on Arch-like systems (uses `pacman` by default).  
- Always review logs at `~/.local/share/zafkiel/zafkiel.log` for details and errors.  
- Use caution with privileged operations and system restores; backups are created where applicable.

## Contributing and License

- Contributions welcome: open focused pull requests and keep commits small. Preserve English log messages and the Zafkiel dramatic tone where appropriate. For major changes, open an issue first.

- License: GNU GENERAL PUBLIC LICENSE 2
---
- Tip: After installing udev integration, plug in a USB device and monitor ~/.local/share/zafkiel/zafkiel.log to confirm automatic mount and any ntfsfix activity.
