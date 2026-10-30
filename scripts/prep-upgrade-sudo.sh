#!/usr/bin/env bash
# Run with sudo, before the quattro upgrade:
#   sudo bash ~/Files/omarchy-setup/scripts/prep-upgrade-sudo.sh
# Stabilizes Wi-Fi (3.x), frees disk space, verifies rollback, backs up iwd.
set -euo pipefail

if (( EUID != 0 )); then
  echo "Run with sudo." >&2
  exit 1
fi

# A. iwd: networkd owns DHCP; disable rtw88 power save.
install -d /etc/iwd
touch /etc/iwd/main.conf
sed -i 's/^EnableNetworkConfiguration=.*/EnableNetworkConfiguration=false/' /etc/iwd/main.conf
grep -q '^EnableNetworkConfiguration=' /etc/iwd/main.conf ||
  sed -i '/^\[General\]/a EnableNetworkConfiguration=false' /etc/iwd/main.conf
if ! grep -q '^\[DriverQuirks\]' /etc/iwd/main.conf; then
  printf '\n[DriverQuirks]\nPowerSaveDisable=rtw88_8821ce\n' >>/etc/iwd/main.conf
elif ! grep -q '^PowerSaveDisable=.*rtw88_8821ce' /etc/iwd/main.conf; then
  sed -i '/^\[DriverQuirks\]/a PowerSaveDisable=rtw88_8821ce' /etc/iwd/main.conf
fi
systemctl restart iwd

# D. Free space.
paccache -rk1 || true

# D. Verify rollback exists.
echo "--- snapper ---"
snapper list || true
command -v limine-snapper-restore >/dev/null && echo "limine-snapper-restore: ok"

# D. Back up saved Wi-Fi profiles (they do NOT migrate to NetworkManager).
backup="/root/iwd-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"
cp -a /var/lib/iwd/. "$backup"/ 2>/dev/null || true
chmod 700 "$backup"
echo "iwd profiles backed up to $backup"

echo "--- result ---"
iw dev wlan0 get power_save || true
echo "Remember: write down the Wi-Fi password; v4 will ask for it again."
