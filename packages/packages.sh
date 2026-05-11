#!/bin/bash
set -euo pipefail

PACKAGES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
echo "  packages.sh — Package installation"
echo "======================================================================"
echo ""

# ─────────────────────────────────────────────────────────────────────
# STEP 1: Official repo packages (pacman)
# ─────────────────────────────────────────────────────────────────────
echo "==> STEP 1: Official Repo Packages"
echo "    Installs all packages listed in pacman.txt using pacman."
echo "    Packages already installed will be skipped automatically."
echo ""

PACMAN_LIST="$PACKAGES_DIR/pacman.txt"

if [[ ! -f "$PACMAN_LIST" ]]; then
  echo "    WARNING: pacman.txt not found at $PACMAN_LIST"
  echo "    Skipping official repo packages."
else
  if prompt "    Install packages from pacman.txt now?"; then
    sudo pacman -S --noconfirm --needed - < "$PACMAN_LIST"
    echo "    Official repo packages installed."
  else
    echo "    Skipped. You can run it manually later with:"
    echo "      sudo pacman -S --noconfirm --needed - < ~/.scripts/packages/pacman.txt"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 2: AUR packages (yay)
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 2: AUR Packages"
echo "    Installs all packages listed in aur.txt using yay."
echo "    Packages already installed will be skipped automatically."
echo ""

AUR_LIST="$PACKAGES_DIR/aur.txt"

if ! command -v yay &>/dev/null; then
  echo "    WARNING: yay is not installed. AUR packages cannot be installed."
  echo "    Run init.sh first to install yay, then re-run this script."
else
  if [[ ! -f "$AUR_LIST" ]]; then
    echo "    WARNING: aur.txt not found at $AUR_LIST"
    echo "    Skipping AUR packages."
  else
    if prompt "    Install packages from aur.txt now?"; then
      yay -S --noconfirm --needed - < "$AUR_LIST"
      echo "    AUR packages installed."
    else
      echo "    Skipped. You can run it manually later with:"
      echo "      yay -S --noconfirm --needed - < ~/.scripts/packages/aur.txt"
    fi
  fi
fi

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> packages.sh complete."
echo ""
