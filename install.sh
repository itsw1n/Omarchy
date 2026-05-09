#!/usr/bin/env bash
set -e

# 1. Backup location outside repo
BACKUP_ROOT="$HOME/Projects/omarchy-backups"
mkdir -p "$BACKUP_ROOT"  # ensure folder exists

# timestamp for backup
TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

# 2. Install Omarchy
echo "=== Installing Omarchy ==="
curl -fsSL https://omarchy.org/install | bash

# 3. Backup existing configs
echo "=== Backing up existing configs ==="
mkdir -p "$BACKUP_DIR"

for dir in dotfiles/*; do
  name=$(basename "$dir")
  if [ -d "$HOME/.config/$name" ]; then
    echo "Backing up $name"
    cp -r "$HOME/.config/$name" "$BACKUP_DIR/"
  fi
done

# optional: create 'latest' symlink
ln -sfn "$BACKUP_DIR" "$BACKUP_ROOT/latest"

# 4. Apply your dotfiles (copy)
echo "=== Applying personal dotfiles ==="
for dir in dotfiles/*; do
  name=$(basename "$dir")
  rm -rf "$HOME/.config/$name"
  cp -r "$dir" "$HOME/.config/"
done

echo "=== Done ==="
echo "Dotfiles applied in ~/.config"
echo "Backup stored at: $BACKUP_DIR"

# 4.5 Optional: Install custom Plymouth boot theme
if [[ -d "dotfiles/omarchy/themes/deymn-plymouth" ]]; then
  read -rp "Install custom Plymouth boot theme (deymn-plymouth)? This requires sudo. (y/N): " INSTALL_THEME
  if [[ "$INSTALL_THEME" =~ ^[Yy]$ ]]; then
    echo "=== Installing custom Plymouth theme ==="
    THEME_SRC="$PWD/dotfiles/omarchy/themes/deymn-plymouth"
    THEME_DEST="/usr/share/plymouth/themes/deymn-plymouth"
    
    sudo mkdir -p "$THEME_DEST"
    sudo cp -a "$THEME_SRC/." "$THEME_DEST/"
    
    # Ensure correct theme file naming
    if [[ -f "$THEME_DEST/omarchy.plymouth" && ! -f "$THEME_DEST/deymn-plymouth.plymouth" ]]; then
      sudo mv "$THEME_DEST/omarchy.plymouth" "$THEME_DEST/deymn-plymouth.plymouth"
    fi
    
    # Update paths in theme config
    sudo sed -i 's|/usr/share/plymouth/themes/omarchy|/usr/share/plymouth/themes/deymn-plymouth|g' "$THEME_DEST/deymn-plymouth.plymouth" 2>/dev/null
    
    # Set as default and rebuild initrd
    sudo plymouth-set-default-theme deymn-plymouth -R
    echo "Custom Plymouth theme installed successfully."
  fi
fi

# 5. Ask if user wants to create symlinks
read -rp "Do you want to create direct symlinks to the repo dotfiles? (y/N): " CREATE_LINK
if [[ "$CREATE_LINK" =~ ^[Yy]$ ]]; then
  for dir in dotfiles/*; do
    name=$(basename "$dir")
    rm -rf "$HOME/.config/$name"
    ln -s "$PWD/$dir" "$HOME/.config/$name"
    echo "Symlink created: ~/.config/$name → $PWD/$dir"
  done
  echo "All dotfiles now linked to repo."
else
  echo "Skipped symlinks. Dotfiles remain copied."
fi

