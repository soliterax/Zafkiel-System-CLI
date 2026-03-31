#!/usr/bin/env bash
# ==========================================================
# ZAFKIEL v3 — Kurumi Tokisaki Linux Power Script (English Edition)
# Fully integrated, modular, Flatpak .desktop auto-repair,
# optional package installer, CLI launcher and 12-hour automated tasks
# ==========================================================
set -euo pipefail
IFS=$'\n\t'

# =========[ COLORS & LOG ]=========
RED="\e[31m"; GRN="\e[32m"; YLW="\e[33m"; BLU="\e[34m"; MAG="\e[35m"; CYN="\e[36m"; RST="\e[0m"
logc() {
    local level="$1"; shift
    local ts; ts="$(date '+%F %T')"
    echo -e "${CYN}[${ts}]${RST} ${MAG}[${level}]${RST} $*"
    mkdir -p "${ZAF_HOME:-${HOME}/.local/share/zafkiel}"
    echo -e "[${ts}] [${level}] $*" >> "${ZAF_HOME:-${HOME}/.local/share/zafkiel}/zafkiel.log"
}

# =========[ PATHS & GLOBALS ]=========
ZAF_HOME="${HOME}/.local/share/zafkiel"
LOG_FILE="${ZAF_HOME}/zafkiel.log"
CONF_FILE="${ZAF_HOME}/config.conf"
CRON_FILE="${ZAF_HOME}/zafkiel-cron.sh"
FLATPAK_FIXER="${ZAF_HOME}/flatpak-desktop-fixer.sh"
USER_APPS="${HOME}/.local/share/applications"
FLATPAK_EXPORTS_USER="${HOME}/.local/share/flatpak/exports/share/applications"
FLATPAK_EXPORTS_SYS="/var/lib/flatpak/exports/share/applications"
LOCAL_BIN="${HOME}/.local/bin"
SCRIPT_PATH="${ZAF_HOME}/zafkiel.sh"   # default, updated at runtime
USB_MOUNTS_FILE="${ZAF_HOME}/usb_mounted.list"
UDEV_RULE_FILE="/etc/udev/rules.d/99-zafkiel-usb-mount.rules"
UDEV_WRAPPER="${ZAF_HOME}/udev-usb-mount-wrapper.sh"
mkdir -p "${ZAF_HOME}" "${USER_APPS}" "${LOCAL_BIN}"

# Default config
RYZEN_TDP_W=${RYZEN_TDP_W:-35}
RYZEN_TCTL_MAX=${RYZEN_TCTL_MAX:-85}
STEAM_COMPATDATA=${STEAM_COMPATDATA:-"${HOME}/.steam/steam/steamapps/compatdata"}
LOADER_DIR=${LOADER_DIR:-/boot/loader/entries}

# =========[ HELPERS ]=========
have() { command -v "$1" &>/dev/null; }
need_sudo() {
    if [[ $(id -u) -ne 0 ]]; then
        if sudo -n true 2>/dev/null; then return 0; fi
        logc WARN "sudo privileges required. Password may be requested."
        sudo -v
    fi
}
confirm() {
    local prompt="$1"
    read -r -p "${prompt} [y/N]: " ans
    [[ "${ans,,}" == "y" ]]
}

# =========[ CONFIG ]=========
load_config() {
    if [[ -f "${CONF_FILE}" ]]; then
        # shellcheck disable=SC1090
        source "${CONF_FILE}"
        logc INFO "Configuration loaded: ${CONF_FILE}"
    else
        logc INFO "Using default configuration."
    fi
}
save_config() {
    cat > "${CONF_FILE}" <<EOF
RYZEN_TDP_W=${RYZEN_TDP_W}
RYZEN_TCTL_MAX=${RYZEN_TCTL_MAX}
STEAM_COMPATDATA="${STEAM_COMPATDATA}"
LOADER_DIR="${LOADER_DIR}"
EOF
    logc OK "Configuration saved: ${CONF_FILE}"
}

# =========[ PACKAGE CHECK & INSTALL ]=========
ensure_packages() {
    local pkgs=("$@")
    local missing=()
    for p in "${pkgs[@]}"; do
        if ! have "$p"; then missing+=("$p"); fi
    done
    if [[ ${#missing[@]} -eq 0 ]]; then
        logc OK "Required packages are present."
        return 0
    fi
    logc INFO "Missing packages: ${missing[*]}"
    if confirm "Install missing packages (pacman)?"; then
        need_sudo
        sudo pacman -Syu --noconfirm "${missing[@]}" || {
            logc ERR "pacman installation failed. Try manual install."
            return 1
        }
        logc OK "Missing packages installed."
    else
        logc INFO "Installation skipped."
        return 2
    fi
}
advise_install() {
    local what="$1"
    logc INFO "Automatic install not supported for ${what}. Please install manually or use an AUR helper."
}

# =========[ CORE MODULES (The bullets) ]=========
aleph_cpu_boost() {
    logc INFO "Zafkiel: 'First bullet, Aleph... Unleashing raw power!'"
    ensure_packages cpupower || true
    if have cpupower; then
        need_sudo
        sudo systemctl enable --now cpupower.service || true
        sudo cpupower frequency-set -g performance || true
        logc OK "cpupower: performance governor set."
    else
        logc WARN "cpupower not found."
    fi
}

beth_inspect() {
    logc INFO "Zafkiel: 'Second bullet, Beth... The system reveals its sight!'"
    if have htop; then htop; else top -b -n1 | head -n20; fi
}

gimel_free_cache() {
    logc INFO "Zafkiel: 'Third bullet, Gimel... Memory cleansed, clarity restored!'"
    need_sudo
    sudo sync
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    logc OK "Cache cleared."
}

dalet_jump() {
    logc INFO "Dalet — Directory Teleport"
    read -r -p "Target directory: " target
    [[ -d "$target" ]] || { logc ERR "Directory not found: $target"; return; }
    logc OK "Switching to: $target"
    cd "$target" || return
    exec "$SHELL"
}

he_clone_process() {
    logc INFO "He — Process Clone"
    read -r -p "Command to run: " cmd
    [[ -n "$cmd" ]] || { logc ERR "Command is empty."; return; }
    nohup bash -lc "$cmd" >/dev/null 2>&1 &
    logc OK "Started (PID $!)."
}

vav_io_benchmark() {
    logc INFO "Vav — I/O Test"
    mkdir -p "${ZAF_HOME}/io"
    if have fio; then
        fio --name=ZafkielIO --filename="${ZAF_HOME}/io/fio.tmp" --size=512M \
            --rw=readwrite --bs=256k --direct=1 --iodepth=16 \
            --ioengine=libaio --numjobs=1 --runtime=20 --time_based
        rm -f "${ZAF_HOME}/io/fio.tmp"
    else
        logc WARN "fio not found. Running simple dd test."
        dd if=/dev/zero of="${ZAF_HOME}/io/dd.tmp" bs=1M count=512 oflag=direct status=progress || true
        rm -f "${ZAF_HOME}/io/dd.tmp"
    fi
    logc OK "I/O test completed."
}

zayin_freeze_pid() {
    logc INFO "Zafkiel: 'Eighth bullet, Zayin... Time itself freezes!'"
    read -r -p "PID: " pid
    [[ -n "$pid" && -d /proc/"$pid" ]] || { logc ERR "Invalid PID."; return; }
    need_sudo
    sudo kill -STOP "$pid"
    logc OK "PID $pid frozen. Resume with: sudo kill -CONT $pid"
}

het_timeshift_restore() {
    logc INFO "Zafkiel: 'Ninth bullet, Het... Turning back the clock of fate!'"
    ensure_packages timeshift || true
    if have timeshift; then
        need_sudo
        sudo timeshift --list || true
        if confirm "Start Timeshift restore?"; then
            need_sudo
            sudo timeshift --restore
        else
            logc INFO "Timeshift restore cancelled."
        fi
    else
        logc WARN "timeshift not installed."
    fi
}

tet_net_trace() {
    logc INFO "Tet — Network Trace (tracepath)"
    read -r -p "Target (default 1.1.1.1): " host
    host="${host:-1.1.1.1}"
    if have tracepath; then
        tracepath "$host" || logc ERR "tracepath failed."
    else
        logc WARN "tracepath not found. Falling back to ping."
        ping -c 4 "$host" || logc ERR "ping failed."
    fi
}

yud_logrotate() {
    logc INFO "Zafkiel: 'Tenth bullet, Yud... Logs rewritten, history reshaped!'"
    need_sudo
    sudo logrotate -f /etc/logrotate.conf || logc ERR "logrotate error."
    logc OK "Logrotate completed."
}

yud_aleph_predict() {
    logc INFO "YudAleph — System Load Prediction"
    uptime
    ps -eo pid,comm,pcpu,pmem --sort=-pcpu | head -n 12
}

yud_bet_timeline() {
    logc INFO "Zafkiel: 'Twelfth bullet, YudBet... Applying amd_pstate toggle.'"
    [[ -d "${LOADER_DIR}" ]] || { logc ERR "Loader entries not found: ${LOADER_DIR}"; return; }
    if ! confirm "Are you sure you want to add amd_pstate=active?"; then
        logc INFO "Operation cancelled."
        return
    fi
    need_sudo
    sudo cp -a "${LOADER_DIR}" "${LOADER_DIR}.bak.$(date +%s)"
    for e in "${LOADER_DIR}"/*.conf; do
        sudo sed -E -i 's/^(options[[:space:]]+)(.*)$/\1\2 amd_pstate=active/' "$e" || true
        logc OK "Updated: $e"
    done
    if confirm "Reboot now?"; then
        need_sudo
        sudo reboot
    fi
}

# =========[ EXTRA POWERS ]=========
ryzen_profile() {
    logc INFO "Zafkiel: 'Thirteenth bullet... Breaking Ryzen's chains!'"
    if ! have ryzenadj; then
        logc ERR "ryzenadj not found."
        return
    fi
    need_sudo
    local mw=$((RYZEN_TDP_W * 1000))
    sudo ryzenadj --stapm-limit="${mw}" --fast-limit="${mw}" --slow-limit="${mw}" --tctl-temp="${RYZEN_TCTL_MAX}" || logc ERR "ryzenadj error."
    logc OK "RyzenAdj applied."
}

run_on_nvidia() {
    logc INFO "Zafkiel: 'Fourteenth bullet... Channeling power to NVIDIA!'"
    read -r -p "Command to run: " cmd
    [[ -n "$cmd" ]] || { logc ERR "Command is empty."; return; }
    env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia DRI_PRIME=1 bash -lc "$cmd"
    logc OK "Command executed (NVIDIA offload)."
}

steam_combatdata_fix() {
    logc INFO "Zafkiel: 'Fifteenth bullet... Restoring order in Steam's realm.'"
    read -r -p "AppID (e.g., 570): " appid
    [[ -n "$appid" ]] || { logc ERR "AppID not provided."; return; }
    local comp="${STEAM_COMPATDATA}/${appid}/pfx/drive_c/users/steamuser/AppData/Local/CombatData"
    local target="${ZAF_HOME}/CombatData_${appid}"
    if [[ -e "$comp" && ! -L "$comp" ]]; then
        mv "$comp" "$target"
        ln -s "$target" "$comp"
        logc OK "CombatData symlink created."
    else
        logc INFO "Symlink not required or already present."
    fi
}

winboat_doctor() {
    logc INFO "Zafkiel: 'Sixteenth bullet... Inspecting virtual machine heart.'"
    lsmod | grep -E 'kvm|kvm_intel|kvm_amd' || true
    if [[ -e /dev/kvm ]]; then
        logc OK "/dev/kvm present"
    else
        logc WARN "/dev/kvm missing"
    fi
}

mirror_optimize() {
    logc INFO "Zafkiel: 'Seventeenth bullet... Reordering mirrors swiftly.'"
    if ! have reflector; then
        logc WARN "reflector not found."
        return
    fi
    need_sudo
    sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist || logc ERR "reflector error."
    logc OK "Mirror list updated."
}

disk_smart_report() {
    logc INFO "Zafkiel: 'Eighteenth bullet... Revealing disk secrets.'"
    if ! have smartctl; then
        logc WARN "smartctl not found."
        return
    fi
    read -r -p "Disk (e.g., /dev/sda): " disk
    [[ -n "$disk" ]] || { logc ERR "Disk not provided."; return; }
    need_sudo
    sudo smartctl -a "$disk" | tee "${ZAF_HOME}/smart_${disk//\//_}.log"
    logc OK "SMART report saved."
}

battery_entropy() {
    logc INFO "Zafkiel: 'Nineteenth bullet... Measuring energy and fate.'"
    if have upower; then
        upower -i "$(upower -e | grep -m1 BAT || true)" 2>/dev/null || true
    else
        logc WARN "upower not found."
    fi
    echo -n "Entropy: "
    cat /proc/sys/kernel/random/entropy_avail || true
}

network_speedtest() {
    logc INFO "Zafkiel: 'Twentieth bullet... Unveiling network speed!'"
    if have speedtest-cli; then
        speedtest-cli
    else
        logc WARN "speedtest-cli not found."
    fi
}

kernel_headers_sync() {
    logc INFO "Kernel Header Sync"
    if have pacman; then
        need_sudo
        sudo pacman -S --needed linux-headers --noconfirm || true
        logc OK "Kernel headers synchronized (if available)."
    else
        logc WARN "pacman not found."
    fi
}

entropy_monitor() {
    logc INFO "Entropy Monitor"
    echo "Entropy: $(cat /proc/sys/kernel/random/entropy_avail)"
}

# =========[ NTFS FIXER ]=========
ntfs_fix_all() {
    logc INFO "Zafkiel: 'Twenty-fifth bullet... Repairing NTFS chains!'"
    if ! have ntfsfix; then
        logc WARN "ntfsfix not found. Package ntfs-3g may be required."
        if confirm "Install ntfs-3g (sudo pacman -S ntfs-3g)?"; then
            need_sudo
            sudo pacman -S --needed ntfs-3g --noconfirm || { logc ERR "ntfs-3g installation failed."; return 1; }
            logc OK "ntfs-3g installed."
        else
            logc INFO "NTFS repair skipped."
            return 0
        fi
    fi

    # Find unmounted NTFS partitions
    mapfile -t ntfs_disks < <(lsblk -o NAME,FSTYPE,MOUNTPOINT -nr | awk '$2=="ntfs" && $3=="" {print "/dev/"$1}')
    if [[ ${#ntfs_disks[@]} -eq 0 ]]; then
        logc INFO "No unmounted NTFS disks found."
        return 0
    fi

    need_sudo
    for d in "${ntfs_disks[@]}"; do
        logc INFO "Starting repair: $d"
        if sudo ntfsfix "$d"; then
            logc OK "Repaired: $d"
        else
            logc ERR "Repair failed: $d"
        fi
    done
}

# =========[ SAFE FLATPAK .DESKTOP FIX + ZAFKIEL INTEGRATION ]=========
_safe_cleanup_dest() {
    local dest="$1"
    if [[ -L "$dest" && ! -e "$dest" ]]; then
        logc WARN "Broken symlink detected: $dest — backing up and removing."
        cp -a "$dest" "${dest}.bak.$(date +%s)" 2>/dev/null || true
        rm -f "$dest" || true
    fi
    if [[ -f "$dest" && ! -L "$dest" ]]; then
        cp -a "$dest" "${dest}.bak.$(date +%s)" 2>/dev/null || true
    fi
}

flatpak_process_app() {
    local appid="$1"
    logc INFO "Flatpak fixer processing: ${appid}"
    local src=""
    local dest="${USER_APPS}/${appid}.desktop"

    _safe_cleanup_dest "$dest"

    for d in "${FLATPAK_EXPORTS_USER}" "${FLATPAK_EXPORTS_SYS}"; do
        if [[ -f "${d}/${appid}.desktop" ]]; then
            src="${d}/${appid}.desktop"
            break
        fi
    done

    if [[ -n "$src" ]]; then
        logc INFO "Found exported .desktop: $src"
        cp -a "$src" "$dest"
        chmod 644 "$dest" || true
        logc OK "Copied: ${src} → ${dest}"
        return 0
    fi

    local name comment icon
    name=$(flatpak info "$appid" 2>/dev/null | awk -F': ' '/^Name:/ {print $2; exit}' || true)
    comment=$(flatpak info "$appid" 2>/dev/null | awk -F': ' '/^Summary:/ {print $2; exit}' || true)
    name=${name:-$appid}
    comment=${comment:-"Flatpak application"}

    for icondir in "${HOME}/.local/share/icons" "/usr/share/icons" "/var/lib/flatpak/exports/share/icons" "${FLATPAK_EXPORTS_USER}/../icons"; do
        if [[ -d "$icondir" ]]; then
            iconfile=$(find "$icondir" -maxdepth 3 -type f -iname "${appid}.*" 2>/dev/null | head -n1 || true)
            if [[ -n "$iconfile" ]]; then
                icon="$iconfile"
                break
            fi
        fi
    done

    cat > "$dest" <<EOF
[Desktop Entry]
Name=${name}
Comment=${comment}
Exec=flatpak run ${appid} %U
Terminal=false
Type=Application
Categories=Utility;
StartupNotify=true
EOF

    if [[ -n "$icon" ]]; then
        echo "Icon=${icon}" >> "$dest"
    else
        echo "Icon=${appid}" >> "$dest"
    fi

    chmod 644 "$dest" || true
    logc OK "Minimal .desktop created: ${dest}"
    return 0
}

flatpak_fix_all() {
    logc INFO "Zafkiel: 'Twenty-first bullet... Repairing application gates.'"
    if ! have flatpak; then
        logc WARN "flatpak not installed."
        if confirm "Install flatpak (sudo pacman -S flatpak)?"; then
            need_sudo
            sudo pacman -S --needed flatpak --noconfirm || { logc ERR "flatpak installation failed."; return 1; }
            logc OK "flatpak installed."
        else
            logc INFO "Flatpak installation skipped; fixer aborted."
            return 0
        fi
    fi

    mapfile -t apps < <(flatpak list --app --columns=application 2>/dev/null || true)
    if [[ ${#apps[@]} -eq 0 ]]; then
        logc INFO "No flatpak applications found."
        return 0
    fi

    for a in "${apps[@]}"; do
        flatpak_process_app "$a" || logc WARN "Error while fixing: $a"
    done

    if have update-desktop-database; then
        update-desktop-database "${USER_APPS}" &>/dev/null || true
        logc OK "Desktop database updated."
    fi

    for f in "${USER_APPS}"/*.desktop; do
        [[ -e "$f" ]] || continue
        if [[ -L "$f" && ! -e "$f" ]]; then
            local base; base="$(basename "$f" .desktop)"
            logc WARN "Broken symlink in user apps: $f — recreating."
            cp -a "$f" "${f}.bak.$(date +%s)" 2>/dev/null || true
            rm -f "$f" || true
            flatpak_process_app "$base" || logc ERR "Recreation failed: $base"
        fi
    done

    ensure_zafkiel_desktop_and_launcher || true
    logc OK "Flatpak .desktop auto-repair completed."
}

ensure_zafkiel_desktop_and_launcher() {
    logc INFO "Verifying ZAFKIEL launcher and .desktop..."
    mkdir -p "${LOCAL_BIN}"
    local target_script
    target_script="${SCRIPT_PATH:-$(readlink -f "${BASH_SOURCE[0]}")}"
    if [[ ! -f "$target_script" ]]; then
        logc ERR "ZAFKIEL script not found: $target_script"
        return 1
    fi
    ln -sf "$target_script" "${LOCAL_BIN}/zafkiel"
    chmod +x "$target_script" "${LOCAL_BIN}/zafkiel" || true
    logc OK "CLI launcher ready: ${LOCAL_BIN}/zafkiel"

    local desktop="${USER_APPS}/zafkiel.desktop"
    _safe_cleanup_dest "$desktop"
    cat > "$desktop" <<EOF
[Desktop Entry]
Name=ZAFKIEL
Comment=ZAFKIEL Power Management
Exec=${LOCAL_BIN}/zafkiel %U
Terminal=true
Type=Application
Categories=System;Utility;
StartupNotify=false
EOF
    chmod 644 "$desktop" || true
    logc OK "ZAFKIEL .desktop created: ${desktop}"

    if have update-desktop-database; then
        update-desktop-database "${USER_APPS}" &>/dev/null || true
    fi
}

# =========[ CRON / SYSTEMD TIMER ]=========
install_flatpak_cron() {
    logc INFO "Installing Flatpak fixer cron..."
    cat > "${FLATPAK_FIXER}" <<SH
#!/usr/bin/env bash
set -euo pipefail
"${SCRIPT_PATH}" --fix-flatpak
SH
    chmod +x "${FLATPAK_FIXER}"
    (crontab -l 2>/dev/null || true; echo "0 */12 * * * ${FLATPAK_FIXER}") | crontab -
    logc OK "Cron job installed: flatpak fixer will run every 12 hours."
}

install_flatpak_timer() {
    logc INFO "Installing Flatpak fixer systemd user timer..."
    local svc="${HOME}/.config/systemd/user/zafkiel-flatpak-fixer.service"
    local timer="${HOME}/.config/systemd/user/zafkiel-flatpak-fixer.timer"
    mkdir -p "$(dirname "$svc")"
    cat > "$svc" <<EOF
[Unit]
Description=ZAFKIEL Flatpak Desktop Fixer

[Service]
Type=oneshot
ExecStart=${SCRIPT_PATH} --fix-flatpak
EOF
    cat > "$timer" <<EOF
[Unit]
Description=Run ZAFKIEL Flatpak Fixer every 12 hours

[Timer]
OnCalendar=*-*-* *:00/12
Persistent=true

[Install]
WantedBy=timers.target
EOF
    chmod 644 "$svc" "$timer"
    systemctl --user daemon-reload || true
    systemctl --user enable --now zafkiel-flatpak-fixer.timer || true
    logc OK "systemd user timer installed and enabled."
}

install_cron_job() {
    cat > "${CRON_FILE}" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
"${ZAF_HOME}/zafkiel.sh" --auto
SH
    chmod +x "${CRON_FILE}"
    (crontab -l 2>/dev/null || true; echo "0 */12 * * * ${CRON_FILE}") | crontab -
    logc OK "Cron job installed: automated tasks every 12 hours."
}

install_systemd_timer() {
    local svc="${HOME}/.config/systemd/user/zafkiel-automate.service"
    local timer="${HOME}/.config/systemd/user/zafkiel-automate.timer"
    mkdir -p "$(dirname "$svc")"
    cat > "$svc" <<EOF
[Unit]
Description=ZAFKIEL Automate Service

[Service]
Type=oneshot
ExecStart=${SCRIPT_PATH} --auto
EOF
    cat > "$timer" <<EOF
[Unit]
Description=Run ZAFKIEL every 12 hours

[Timer]
OnCalendar=*-*-* *:00/12
Persistent=true

[Install]
WantedBy=timers.target
EOF
    chmod 644 "$svc" "$timer"
    systemctl --user daemon-reload || true
    systemctl --user enable --now zafkiel-automate.timer || true
    logc OK "systemd user timer installed."
}

# =========[ CLI LAUNCHER ]=========
create_cli_launcher() {
    logc INFO "Zafkiel: 'Twenty-fourth bullet... Leaving my soul in the command line.'"
    logc INFO "Creating CLI launcher: ${LOCAL_BIN}/zafkiel"
    if [[ ! -f "${SCRIPT_PATH}" ]]; then
        read -r -p "Enter script path (Enter for default ${SCRIPT_PATH}): " sp
        SCRIPT_PATH="${sp:-${SCRIPT_PATH}}"
    fi
    if [[ ! -f "${SCRIPT_PATH}" ]]; then
        logc ERR "Script file not found: ${SCRIPT_PATH}"
        return 1
    fi
    ln -sf "${SCRIPT_PATH}" "${LOCAL_BIN}/zafkiel"
    chmod +x "${SCRIPT_PATH}" "${LOCAL_BIN}/zafkiel"
    if [[ ":$PATH:" != *":${LOCAL_BIN}:"* ]]; then
        logc WARN "${LOCAL_BIN} not in PATH."
        echo -e "${YLW}Tip:${RST} To add it to your PATH, append the following line to your shell profile:"
        echo -e "${GRN}export PATH=\"\$HOME/.local/bin:\$PATH\"${RST}"
        if confirm "Add this line automatically to ~/.profile?"; then
            grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "${HOME}/.profile" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.profile"
            logc OK "PATH line added to ~/.profile."
            source "${HOME}/.profile" 2>/dev/null || true
        else
            logc INFO "PATH addition skipped."
        fi
    fi
    logc OK "CLI launcher ready. Run 'zafkiel' in terminal."
}

# =========[ AUTOMATED TASKS ]=========
auto_tasks() {
    logc INFO "Zafkiel: 'Automated tasks started (12-hour cycle)'"
    gimel_free_cache
    yud_logrotate
    ryzen_profile || true
    mirror_optimize || true
    flatpak_fix_all || true
    logc OK "Automated tasks completed."
}

# =========[ ASCII BANNER ]=========
banner() {
cat <<'EOF'
╔══════════════════════════════════════════════════════════════════╗
║   ZAFKIEL v3 — Kurumi Tokisaki Linux Power Script                ║
║   Fully integrated • Flatpak .desktop auto-repair • CLI launcher ║
╚══════════════════════════════════════════════════════════════════╝
EOF
}

# =========[ USB NTFS AUTO-MOUNT HELPERS ]=========
# Track mounts in USB_MOUNTS_FILE so they can be unmounted/cleaned later.
_record_mount() {
    local device="$1"
    local mp="$2"
    mkdir -p "$(dirname "$USB_MOUNTS_FILE")"
    # store device|mountpoint
    echo "${device}|${mp}" >> "${USB_MOUNTS_FILE}"
    logc INFO "Recorded mount: ${device} -> ${mp}"
}
_remove_mount_record() {
    local device="$1"
    if [[ -f "${USB_MOUNTS_FILE}" ]]; then
        grep -v "^${device}|" "${USB_MOUNTS_FILE}" > "${USB_MOUNTS_FILE}.tmp" || true
        mv -f "${USB_MOUNTS_FILE}.tmp" "${USB_MOUNTS_FILE}" || true
    fi
}

# Attempt to mount a single device; if mount fails and it's NTFS, run ntfsfix and retry.
_mount_device_with_fix() {
    local device="$1"
    local mp="/mnt/$(basename "$device")"
    mkdir -p "$mp"
    logc INFO "Attempting mount: ${device} -> ${mp}"
    if sudo mount -t auto "$device" "$mp"; then
        logc OK "Mounted: ${device} -> ${mp}"
        _record_mount "$device" "$mp"
        return 0
    fi

    # If mount failed and device is NTFS, try ntfsfix then mount again
    local fstype
    fstype=$(lsblk -no FSTYPE "$device" 2>/dev/null || true)
    if [[ "${fstype,,}" == "ntfs" ]]; then
        if ! have ntfsfix; then
            logc WARN "ntfsfix not found. Install ntfs-3g to enable NTFS repair."
            return 1
        fi
        logc WARN "Mount failed; running ntfsfix on ${device}"
        if sudo ntfsfix "$device"; then
            logc INFO "ntfsfix completed for ${device}; retrying mount."
            if sudo mount -t auto "$device" "$mp"; then
                logc OK "Mounted after ntfsfix: ${device} -> ${mp}"
                _record_mount "$device" "$mp"
                return 0
            else
                logc ERR "Mount still failed after ntfsfix: ${device}"
                return 1
            fi
        else
            logc ERR "ntfsfix failed on ${device}"
            return 1
        fi
    else
        logc ERR "Mount failed and filesystem is not NTFS (or unknown): ${device} (fstype=${fstype})"
        return 1
    fi
}

# Public function: scan for removable block devices and try to mount them (NTFS fix if needed).
usb_ntfs_auto_mount() {
    logc INFO "Zafkiel: 'Twenty-sixth bullet... Binding NTFS to destiny!'"
    # Find removable partitions (exclude system disks). Use lsblk to find partitions with RM=1 or by checking /sys/block/*/removable
    mapfile -t candidates < <(lsblk -o NAME,RM,TYPE -nr | awk '$2=="1" && $3=="part" {print "/dev/"$1}')
    # Fallback: include any partition on sd[b-z] if no removable found
    if [[ ${#candidates[@]} -eq 0 ]]; then
        mapfile -t candidates < <(lsblk -o NAME,FSTYPE,MOUNTPOINT -nr | awk '$2!="" && $3=="" && $1 ~ /^sd[b-z][0-9]+$/ {print "/dev/"$1}')
    fi

    if [[ ${#candidates[@]} -eq 0 ]]; then
        logc INFO "No candidate removable partitions detected."
        return 0
    fi

    need_sudo
    for dev in "${candidates[@]}"; do
        _mount_device_with_fix "$dev" || logc WARN "Failed to mount: $dev"
    done
}

# Unmount all mounts recorded by this script
usb_ntfs_unmount() {
    logc INFO "Zafkiel: 'Twenty-seventh bullet... Releasing NTFS from fate!'"
    if [[ ! -f "${USB_MOUNTS_FILE}" ]]; then
        logc INFO "No recorded USB mounts to unmount."
        return 0
    fi
    need_sudo
    # Read file lines device|mount
    while IFS='|' read -r device mp; do
        [[ -z "$device" || -z "$mp" ]] && continue
        if mountpoint -q "$mp"; then
            logc INFO "Unmounting: ${mp} (device: ${device})"
            if sudo umount "$mp"; then
                logc OK "Unmounted: ${mp}"
                _remove_mount_record "$device"
                # Optionally remove empty mountpoint
                rmdir --ignore-fail-on-non-empty "$mp" 2>/dev/null || true
            else
                logc ERR "Failed to unmount: ${mp}"
            fi
        else
            logc INFO "Mountpoint not active: ${mp} — removing record."
            _remove_mount_record "$device"
        fi
    done < "${USB_MOUNTS_FILE}"
}

# Install udev rule and wrapper to auto-run mount on device add
usb_ntfs_install_udev() {
    logc INFO "Installing udev rule for automatic USB mount..."
    if [[ $(id -u) -ne 0 ]]; then
        logc WARN "Root required to write udev rule. Prompting for sudo."
    fi
    need_sudo

    # Create wrapper script that udev will call (it runs as root)
    cat > "${UDEV_WRAPPER}" <<'SH'
#!/usr/bin/env bash
# udev wrapper: receives device node as $1 and calls zafkiel script to mount it
DEVNODE="$1"
ZAF_SCRIPT="${HOME}/.local/share/zafkiel/zafkiel.sh"
# If script exists, call mount helper with device
if [[ -x "${ZAF_SCRIPT}" ]]; then
    # Run in background to avoid blocking udev
    "${ZAF_SCRIPT}" --udev-mount "${DEVNODE}" >/dev/null 2>&1 &
fi
SH
    chmod +x "${UDEV_WRAPPER}"

    # Write udev rule: call wrapper on partition add events for removable devices
    # Use %k to pass kernel name; wrapper expects /dev/<name>
    cat > "${UDEV_RULE_FILE}" <<EOF
ACTION=="add", KERNEL=="sd[b-z][0-9]", SUBSYSTEM=="block", ENV{ID_BUS}=="usb", RUN+="${UDEV_WRAPPER} /dev/%k"
EOF

    logc OK "Udev rule installed: ${UDEV_RULE_FILE}"
    logc INFO "Reloading udev rules..."
    sudo udevadm control --reload-rules && sudo udevadm trigger || true
    logc OK "udev rules reloaded."
}

# Remove udev rule and wrapper
usb_ntfs_remove_udev() {
    logc INFO "Removing udev rule and wrapper..."
    need_sudo
    if [[ -f "${UDEV_RULE_FILE}" ]]; then
        sudo rm -f "${UDEV_RULE_FILE}" || true
        logc OK "Removed udev rule: ${UDEV_RULE_FILE}"
    else
        logc INFO "Udev rule not found: ${UDEV_RULE_FILE}"
    fi
    if [[ -f "${UDEV_WRAPPER}" ]]; then
        rm -f "${UDEV_WRAPPER}" || true
        logc OK "Removed wrapper: ${UDEV_WRAPPER}"
    else
        logc INFO "Wrapper not found: ${UDEV_WRAPPER}"
    fi
    sudo udevadm control --reload-rules || true
    logc OK "udev rules reloaded."
}

# Helper invoked by udev wrapper: mount a single device passed as argument
# This mode is triggered when script is called with --udev-mount /dev/sdX1
_udev_mount_mode() {
    local dev="$1"
    if [[ -z "$dev" ]]; then
        logc ERR "No device provided to udev mount mode."
        return 1
    fi
    need_sudo
    _mount_device_with_fix "$dev"
}

# =========[ FLATPAK CRON/TIMER INSTALLERS (already present above) ]=========
install_flatpak_cron || true

# =========[ MENU ]=========
menu() {
    banner
    echo -e "${MAG}[ 1]${RST} Aleph  - CPU Boost        ${MAG}[ 2]${RST} Beth  - System Inspect"
    echo -e "${MAG}[ 3]${RST} Gimel  - RAM Cache       ${MAG}[ 4]${RST} Dalet - Teleport"
    echo -e "${MAG}[ 5]${RST} He     - Process Clone   ${MAG}[ 6]${RST} Vav   - I/O Test"
    echo -e "${MAG}[ 7]${RST} Zayin  - Freeze PID      ${MAG}[ 8]${RST} Het   - Timeshift Restore"
    echo -e "${MAG}[ 9]${RST} Tet    - tracepath       ${MAG}[10]${RST} Yud   - Logrotate"
    echo -e "${MAG}[11]${RST} YudAleph - Load Predict  ${MAG}[12]${RST} YudBet - amd_pstate toggle"
    echo -e "${CYN}--- EXTRA POWERS ---${RST}"
    echo -e "${CYN}[13]${RST} RyzenAdj Profile   ${CYN}[14]${RST} NVIDIA Offload"
    echo -e "${CYN}[15]${RST} Steam CombatData Fix ${CYN}[16]${RST} WinBoat Doctor"
    echo -e "${CYN}[17]${RST} Mirror Optimize   ${CYN}[18]${RST} Disk SMART Report"
    echo -e "${CYN}[19]${RST} Battery & Entropy ${CYN}[20]${RST} Network Speedtest"
    echo -e "${CYN}[21]${RST} Flatpak .desktop Fixer ${CYN}[22]${RST} Install Flatpak Cron"
    echo -e "${CYN}[23]${RST} Install Flatpak Timer ${CYN}[24]${RST} Create CLI Launcher"
    echo -e "${CYN}[25]${RST} NTFS Disk Fixer"
    echo -e "${CYN}[26]${RST} USB NTFS Auto-Mount ${CYN}[27]${RST} USB NTFS Unmount"
    echo -e "${CYN}[28]${RST} Install udev auto-mount ${CYN}[29]${RST} Remove udev auto-mount"
    echo -e "${YLW}[I]${RST} Installer (install missing pkgs + optional setups)  ${YLW}[S]${RST} Save Configuration  ${RED}[0]${RST} Exit"
    read -r -p "Selection (letter or number): " sel
    case "${sel,,}" in
        1|aleph) aleph_cpu_boost ;;
        2|beth) beth_inspect ;;
        3|gimel) gimel_free_cache ;;
        4|dalet) dalet_jump ;;
        5|he) he_clone_process ;;
        6|vav) vav_io_benchmark ;;
        7|zayin) zayin_freeze_pid ;;
        8|het) het_timeshift_restore ;;
        9|tet) tet_net_trace ;;
        10|yud) yud_logrotate ;;
        11|yudaleph) yud_aleph_predict ;;
        12|yudbet) yud_bet_timeline ;;
        13) ryzen_profile ;;
        14) run_on_nvidia ;;
        15) steam_combatdata_fix ;;
        16) winboat_doctor ;;
        17) mirror_optimize ;;
        18) disk_smart_report ;;
        19) battery_entropy ;;
        20) network_speedtest ;;
        21) flatpak_fix_all ;;
        22) install_flatpak_cron ;;
        23) install_flatpak_timer ;;
        24) create_cli_launcher ;;
        25|ntfsfix) ntfs_fix_all ;;
        26) usb_ntfs_auto_mount ;;
        27) usb_ntfs_unmount ;;
        28) usb_ntfs_install_udev ;;
        29) usb_ntfs_remove_udev ;;
        i)
            logc INFO "Installer started."
            ensure_packages cpupower rsync coreutils util-linux || true
            if confirm "Install AUR helper (paru)? (manual build will be required)"; then
                advise_install "AUR helper (paru)"
            fi
            if confirm "Install Flatpak fixer and add cron/timer?"; then
                flatpak_fix_all || true
                if confirm "Install cron for flatpak fixer?"; then install_flatpak_cron; fi
                if confirm "Install systemd user timer for flatpak fixer?"; then install_flatpak_timer; fi
            fi
            if confirm "Create CLI launcher (zafkiel command)?"; then create_cli_launcher; fi
            logc OK "Installer finished."
            ;;
        s) save_config; logc INFO "Configuration saved." ;;
        0|q|quit) logc INFO "Exiting."; exit 0 ;;
        *) logc ERR "Invalid selection: $sel" ;;
    esac
}

# =========[ ARG PARSING ]=========
load_config
# Ensure SCRIPT_PATH points to this file
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"

case "${1:-}" in
    --install-cron) install_cron_job; exit 0 ;;
    --install-timer) install_systemd_timer; exit 0 ;;
    --auto) auto_tasks; exit 0 ;;
    --fix-flatpak) flatpak_fix_all; exit 0 ;;
    --install-flatpak-cron) install_flatpak_cron; exit 0 ;;
    --install-flatpak-timer) install_flatpak_timer; exit 0 ;;
    --create-cli) create_cli_launcher; exit 0 ;;
    --ntfs-fix) ntfs_fix_all; exit 0 ;;
    --udev-mount) shift; _udev_mount_mode "$1"; exit 0 ;;
esac

# =========[ MAIN LOOP ]=========
while true; do
    menu
    read -r -p "Continue (Enter) / Quit (q): " ans
    [[ "${ans,,}" == "q" ]] && break
done

logc INFO "ZAFKIEL script terminated."
