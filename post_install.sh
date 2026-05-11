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
echo "  post_install.sh — Final system configuration"
echo "======================================================================"
echo ""

# ─────────────────────────────────────────────────────────────────────
# STEP 1: Set default shell to fish
# ─────────────────────────────────────────────────────────────────────
echo "==> STEP 1: Default Shell"
echo "    Sets fish as your default login shell system-wide using chsh."
echo "    This won't take effect until you log out and back in."
echo "    Note: your kitty config already launches fish, but this makes"
echo "    fish the default everywhere including TTY login sessions."
echo ""

if prompt "    Set fish as your default shell now?"; then
  if ! command -v fish &>/dev/null; then
    echo "    WARNING: fish is not installed. Run packages.sh first."
  else
    chsh -s /usr/bin/fish
    echo "    Default shell set to fish."
    echo "    Log out and back in for this to take effect."
  fi
else
  echo "    Skipped. You can set it manually later with:"
  echo "      chsh -s /usr/bin/fish"
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 2: Set up XDG user directories
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 2: XDG User Directories"
echo "    Creates standard home directories like Documents, Downloads,"
echo "    Pictures, Music, and Videos. These are expected by many apps"
echo "    and your Hyprland config may reference them."
echo ""

if prompt "    Create XDG user directories now?"; then
  xdg-user-dirs-update
  echo "    XDG user directories created."
else
  echo "    Skipped. You can run manually later with:"
  echo "      xdg-user-dirs-update"
fi

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> post_install.sh complete."
echo "    Remember to reboot or re-login to apply all changes."
echo ""
