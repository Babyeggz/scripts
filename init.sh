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

# ─────────────────────────────────────────────────────────────────────
# STEP 1: Mount thumb drive and read GitHub token
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 1: GitHub Token"
echo "    This script reads your GitHub personal access token from your"
echo "    EGGZDRIVE thumb drive. The token is used to authenticate with"
echo "    GitHub so we can clone your repos and push commits."
echo ""

# Ensure udiskie is available for mounting drives
sudo pacman -S --noconfirm --needed udiskie

TOKEN_PATH="/run/media/$USER/EGGZDRIVE/github_token.txt"
if [[ ! -f "$TOKEN_PATH" ]]; then
  echo ""
  echo "ERROR: Token file not found at $TOKEN_PATH — is the drive mounted?"
  echo "       Try running: udiskie-mount -a"
  echo ""
  exit 1
fi

GITHUB_TOKEN=$(cat "$TOKEN_PATH")
echo "    Token found."

# ─────────────────────────────────────────────────────────────────────
# STEP 2: Install git, base-devel, gh
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 2: Core Dependencies"
echo "    We need git, base-devel (required to build AUR packages),"
echo "    and github-cli (gh) to authenticate with GitHub."
echo ""

if prompt "    Install git, base-devel, and github-cli now?"; then
  sudo pacman -S --noconfirm --needed git base-devel github-cli
  echo "    Core dependencies installed."
else
  echo "    Skipped. Note: git and gh are required for later steps."
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 3: Install yay (AUR helper)
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 3: AUR Helper (yay)"
echo "    yay is an AUR helper that lets you install packages from the"
echo "    Arch User Repository, which has thousands of community packages"
echo "    not available in the official repos. It wraps pacman so you"
echo "    use it the same way."
echo ""

if ! command -v yay &>/dev/null; then
  if prompt "    yay is not installed. Install it now?"; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
    echo "    yay installed."
  else
    echo "    Skipped. AUR packages will not be available without an AUR helper."
  fi
else
  echo "    yay is already installed, skipping."
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 4: Authenticate with GitHub
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 4: GitHub Authentication"
echo "    We will now authenticate the gh CLI tool using your token and"
echo "    configure git to use gh as a credential helper. This means all"
echo "    git operations (clone, push, pull) will use your token"
echo "    automatically without prompting for a password."
echo ""

if prompt "    Authenticate with GitHub now?"; then
  echo "$GITHUB_TOKEN" | gh auth login --with-token
  git config --global user.email "Babyeggz@users.noreply.github.com"
  git config --global user.name "Babyeggz"
  gh auth setup-git
  echo "    GitHub authentication configured."
else
  echo "    Skipped. Cloning your repos will fail without authentication."
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 5: Clone scripts repo
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 5: Scripts Repository"
echo "    Your scripts are stored in a normal git repository on GitHub."
echo "    We will clone it into ~/.scripts so that install.sh and all"
echo "    sub-scripts are available on disk before we run them."
echo ""

SCRIPTS_REPO="https://github.com/Babyeggz/scripts.git"
SCRIPTS_DIR="$HOME/.scripts"

if [[ -d "$SCRIPTS_DIR" ]]; then
  echo "    ~/.scripts already exists — scripts repo may already be cloned."
  if prompt "    Re-clone and overwrite?"; then
    rm -rf "$SCRIPTS_DIR"
  else
    echo "    Skipped scripts clone."
  fi
fi

if [[ ! -d "$SCRIPTS_DIR" ]]; then
  if prompt "    Clone scripts repo from $SCRIPTS_REPO?"; then
    git clone "$SCRIPTS_REPO" "$SCRIPTS_DIR"
    echo "    Scripts repo cloned to ~/.scripts."
  else
    echo "    Skipped. You can clone manually later with:"
    echo "      git clone $SCRIPTS_REPO ~/.scripts"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 6: Run install.sh (packages first)
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 6: Run install.sh"
echo "    Now that the scripts repo is on disk we will run install.sh"
echo "    to install all your packages. Packages are installed before"
echo "    your dotfiles land so that all programs your configs reference"
echo "    are already present."
echo ""

INSTALL_SCRIPT="$SCRIPTS_DIR/install.sh"

if [[ ! -f "$INSTALL_SCRIPT" ]]; then
  echo "    WARNING: install.sh not found at $INSTALL_SCRIPT"
  echo "    The scripts repo may not have been cloned in step 5."
  echo "    Cannot proceed with package installation."
else
  if prompt "    Run install.sh now?"; then
    bash "$INSTALL_SCRIPT"
  else
    echo "    Skipped. You can run it manually later with:"
    echo "      bash ~/.scripts/install.sh"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# STEP 7: Clone and checkout dotfiles repo
# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> STEP 7: Dotfiles Repository"
echo "    Your dotfiles are stored as a bare git repository on GitHub."
echo "    We will clone it into ~/.cfg and check out your config files"
echo "    directly into your home directory. Any files that would be"
echo "    overwritten will be backed up to ~/.config-backup/ first."
echo ""

DOTFILES_REPO="https://github.com/Babyeggz/dotfiles.git"
CFG_DIR="$HOME/.cfg"

if [[ -d "$CFG_DIR" ]]; then
  echo "    ~/.cfg already exists — dotfiles repo may already be cloned."
  if prompt "    Re-clone and overwrite?"; then
    rm -rf "$CFG_DIR"
  else
    echo "    Skipped dotfiles clone."
  fi
fi

if [[ ! -d "$CFG_DIR" ]]; then
  if prompt "    Clone dotfiles repo from $DOTFILES_REPO?"; then
    # Prevent recursion issues
    grep -qxF '.cfg' "$HOME/.gitignore" 2>/dev/null || echo ".cfg" >> "$HOME/.gitignore"

    git clone --bare "$DOTFILES_REPO" "$CFG_DIR"

    function config {
      /usr/bin/git --git-dir="$CFG_DIR" --work-tree="$HOME" "$@"
    }

    config config status.showUntrackedFiles no

    echo "    Checking out dotfiles..."
    if ! config checkout 2>/dev/null; then
      echo "    Conflicting files detected. Backing up to ~/.config-backup/..."
      mkdir -p "$HOME/.config-backup"
      config checkout 2>&1 \
        | grep -E "^\s+\." \
        | awk '{print $1}' \
        | xargs -I{} sh -c 'mkdir -p "$(dirname "$HOME/.config-backup/{}")" && mv "$HOME/{}" "$HOME/.config-backup/{}"'
      config checkout
    fi

    echo "    Dotfiles checked out successfully."
  else
    echo "    Skipped. You can clone manually later with:"
    echo "      git clone --bare $DOTFILES_REPO ~/.cfg"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "==> All steps complete. Reboot or re-login to apply all changes."
echo ""
