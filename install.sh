i#!/bin/bash
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
echo "  install.sh — Package installation and system configuration"
echo "======================================================================"
echo ""

# ─────────────────────────────────────────────────────────────────────
# STEP 1: Install packages
# ─────────────────────────────────────────────────────────────────────
echo "==> STEP 1: Package Installation"
echo "    This will install all packages defined in your package lists:"
echo "      ~/.scripts/packages/pacman.txt — official repo packages"
echo "      ~/.scripts/packages/aur.txt    — AUR packages via yay"
echo ""

if prompt "    Run packages.sh now?"; then
  bash "$SCRIPTS_DIR/packages/packages.sh"
  echo "    Packages installed."
else
  echo "    Skipped. You can run it manually later with:"
  echo "      bash ~/.scripts/packages/packages.sh"
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 2: Enable system services
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 2: System Services"
echo "    This will enable and start systemd services your system needs,"
echo "    such as NetworkManager, bluetooth, and udiskie. Services are"
echo "    enabled to start automatically on every boot."
echo ""

if prompt "    Run services.sh now?"; then
  bash "$SCRIPTS_DIR/services.sh"
  echo "    Services enabled."
else
  echo "    Skipped. You can run it manually later with:"
  echo "      bash ~/.scripts/services.sh"
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 3: Post-install configuration
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 3: Post-Install Configuration"
echo "    This runs any final setup steps that require packages to already"
echo "    be installed, such as changing your default shell to zsh and"
echo "    initializing any tools that need a first-run setup."
echo ""

if prompt "    Run post_install.sh now?"; then
  bash "$SCRIPTS_DIR/post_install.sh"
  echo "    Post-install configuration complete."
else
  echo "    Skipped. You can run it manually later with:"
  echo "      bash ~/.scripts/post_install.sh"
fi

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> install.sh complete."
echo ""
