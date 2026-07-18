# Omarchy Setup

This is my personal Omarchy setup — my copy in case I switch to a different machine in the future. This setup applies my dotfiles, lock-screen branding, and a mecha-themed Waybar that tracks the active Omarchy theme. Symlinks are optional so edits in the repo reflect instantly.

**Status:** In Progress

---
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/ac52d359-9f85-436b-a52c-05bc565c4db8" />
<img width="2048" height="1536" alt="lockscreen" src="https://github.com/user-attachments/assets/f8464f0c-9ce2-424d-ba77-e7521c99b137" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/40451dc9-fc48-4ed2-9050-34d22bcd4488" />

## What's in here

- **Hyprland** — monitors, input, bindings, idle/lock, screensaver, night light
- **Waybar** — [mechabar](https://github.com/sejjy/mechabar) with Omarchy color integration
- **Lock branding** — DEYMN Plymouth/SDDM logo that auto-recolors to the active theme accent
- **Omarchy hooks** — re-applies lock branding after `omarchy-update`

## What this setup does

1. **Install Omarchy** using the official installer.
2. **Backup existing configs** from `~/.config/*` that match the dotfiles in this repo.
   - Backups are stored in `~/Projects/omarchy-backups/YYYY-MM-DD_HH-MM-SS`
   - A symlink `latest` points to the most recent backup.
3. **Apply personal dotfiles** by copying them into `~/.config/`.
4. **Install DEYMN lock wrapper** — patches `omarchy-plymouth-set` so every theme change recolors the lock logo with the current accent. Also offers to apply the logo immediately (requires sudo).
5. **Prompt for symlinks** — after dotfiles are applied, the script asks if you want direct symlinks from the repo to `~/.config/` for instant updates.

## How to install

```bash
mkdir -p ~/Files
git clone https://github.com/deymn/omarchy-setup.git ~/Files/omarchy-setup
cd ~/Files/omarchy-setup
./install.sh
```

---

## Future Plans

- Add more dotfiles (Kitty, Ghostty, etc.)
- Improve symlink automation
- Make script more public-friendly
