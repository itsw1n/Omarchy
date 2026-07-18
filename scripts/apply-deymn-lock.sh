#!/usr/bin/env bash
set -e

DEYMN_GRAY="/usr/local/share/deymn-plymouth/logo-gray.png"
THEME_DIR="/usr/share/plymouth/themes/omarchy"
SDDM_DIR="/usr/share/sddm/themes/omarchy"
STAGING="/tmp/deymn-lock-recolor"

# Fall back to repo grayscale logo if persistent backup missing
if [[ ! -f "$DEYMN_GRAY" ]]; then
  REPO_GRAY="$HOME/Files/omarchy-setup/assets/logo/logo-gray.png"
  if [[ -f "$REPO_GRAY" ]]; then
    DEYMN_GRAY="$REPO_GRAY"
  else
    echo "Error: No grayscale logo found." >&2
    exit 1
  fi
fi

# Determine the active theme
THEME_NAME=$(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null || echo "")
if [[ -z "$THEME_NAME" ]]; then
  echo "Error: Could not determine active Omarchy theme." >&2
  exit 1
fi

# Find the theme's colors.toml (local override takes priority)
if [[ -f "$HOME/.config/omarchy/themes/$THEME_NAME/colors.toml" ]]; then
  COLORS_TOML="$HOME/.config/omarchy/themes/$THEME_NAME/colors.toml"
elif [[ -f "$HOME/.local/share/omarchy/themes/$THEME_NAME/colors.toml" ]]; then
  COLORS_TOML="$HOME/.local/share/omarchy/themes/$THEME_NAME/colors.toml"
else
  echo "Error: Could not find colors.toml for theme '$THEME_NAME'." >&2
  exit 1
fi

# Extract accent color
accent=$(awk -F'"' '/^accent/{print $2}' "$COLORS_TOML")
if [[ -z "$accent" ]]; then
  echo "Error: Could not read accent color from $COLORS_TOML" >&2
  exit 1
fi

echo "Using theme: $THEME_NAME (accent: $accent)"

# Recolor and deploy
mkdir -p "$STAGING"
magick "$DEYMN_GRAY" -channel RGB +level-colors "${accent}","${accent}" "$STAGING/logo.png"
sudo cp "$STAGING/logo.png" "$THEME_DIR/logo.png"
sudo cp "$STAGING/logo.png" "$SDDM_DIR/logo.png" 2>/dev/null || true
rm -rf "$STAGING"

# Update persistent backup
sudo mkdir -p /usr/local/share/deymn-plymouth
sudo cp "$DEYMN_GRAY" /usr/local/share/deymn-plymouth/logo-gray.png

if command -v limine-mkinitcpio &>/dev/null; then
  sudo limine-mkinitcpio
else
  sudo mkinitcpio -P
fi

echo "DEYMN lock logo applied with $accent accent."
