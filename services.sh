#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────
# Helper: prompt for y/n and return 0 for yes, 1 for no
# ─────────────────────────────────────────────────────────────────────
prompt() {
  while true; do
    read -rp "$1 [y/n]: " yn
    case "$yn" in
    [Yy]) return 0 ;;
    [Nn]) return 1 ;;
    *) echo "  Please answer y or n." ;;
    esac
  done
}

echo ""
echo "======================================================================"
echo "  services.sh — Systemd service configuration"
echo "======================================================================"
echo ""

# ─────────────────────────────────────────────────────────────────────
# STEP 1: Networking
# ─────────────────────────────────────────────────────────────────────
echo "==> STEP 1: Networking"
echo "    Enables NetworkManager and its dispatcher service so your"
echo "    network connections are managed automatically on boot."
echo ""

if prompt "    Enable NetworkManager services now?"; then
  sudo systemctl enable --now NetworkManager.service
  sudo systemctl enable --now NetworkManager-dispatcher.service
  sudo systemctl enable --now NetworkManager-wait-online.service
  echo "    Networking services enabled."
else
  echo "    Skipped. You can enable manually later with:"
  echo "      sudo systemctl enable --now NetworkManager.service"
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 2: Bluetooth
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 2: Bluetooth"
echo "    Enables the bluetooth service so your bluetooth devices"
echo "    are available and can connect automatically on boot."
echo ""

if prompt "    Enable bluetooth now?"; then
  sudo systemctl enable --now bluetooth.service
  echo "    Bluetooth enabled."
else
  echo "    Skipped. You can enable manually later with:"
  echo "      sudo systemctl enable --now bluetooth.service"
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 3: Printing (CUPS)
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 3: Printing (CUPS)"
echo "    Enables the CUPS printing service, its socket, and path unit"
echo "    so printers are available and the service starts on demand."
echo ""

if prompt "    Enable CUPS printing services now?"; then
  sudo systemctl enable --now cups.service
  sudo systemctl enable --now cups.socket
  sudo systemctl enable --now cups.path
  echo "    CUPS printing services enabled."
else
  echo "    Skipped. You can enable manually later with:"
  echo "      sudo systemctl enable --now cups.service"
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 4: SSD Trim
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 4: SSD Trim (fstrim)"
echo "    Enables the weekly fstrim timer which runs TRIM on your SSD"
echo "    to maintain performance and extend its lifespan over time."
echo ""

if prompt "    Enable fstrim timer now?"; then
  sudo systemctl enable fstrim.timer
  echo "    fstrim timer enabled."
else
  echo "    Skipped. You can enable manually later with:"
  echo "      sudo systemctl enable fstrim.timer"
fi

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> services.sh complete."
echo ""

# ─────────────────────────────────────────────────────────────────────
# STEP 5: Auto-connect Shokz OpenDots on login
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 5: Bluetooth auto-connect (Shokz OpenDots)"
echo "    Enables a user systemd service that automatically reconnects"
echo "    your Shokz OpenDots ONE on each login."
echo ""

if prompt "    Enable Shokz auto-connect service now?"; then
  systemctl --user enable --now bt-connect-shokz.service
  echo "    Shokz auto-connect enabled."
else
  echo "    Skipped. You can enable manually later with:"
  echo "      systemctl --user enable --now bt-connect-shokz.service"
fi
