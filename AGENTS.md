# Omarchy Setup — AI Assistant Guide

## Prerequisites
- Arch Linux with Hyprland already running
- Omarchy installed (if not, `curl -fsSL https://omarchy.org/install | bash`)
- Required tools: jq, ImageMagick (`magick`), `walker`
- Plymouth theme system (for lock screen branding)
- SDDM (for display manager logo)

## Setup workflow
1. Clone repo to `~/Files/omarchy-setup`
2. Read `install.sh` — it does: Omarchy install → backup → copy dotfiles → DEYMN wrapper → symlink prompt
3. Ask user if they want **symlinks** or **copy**:
   - Symlinks: edits in repo reflect instantly in ~/.config. Repo path must stay put.
   - Copy: standalone, no dependency on repo location.
4. Run `./install.sh` or execute steps individually if customization needed

## Symlinks — no extra downloads needed
Symlinks just point `~/.config/<name>` → `dotfiles/<name>` in the clone. No additional packages required.

## Dotfile mapping
| Repo path | Installed to |
|---|---|
| `dotfiles/hypr/` | `~/.config/hypr/` |
| `dotfiles/waybar/` | `~/.config/waybar/` |
| `dotfiles/omarchy/` | `~/.config/omarchy/` |

## Post-install checks
- `hyprctl monitors` — display config active?
- Lock screen shows DEYMN logo with theme accent?
- `pkill -SIGUSR2 waybar` — Waybar picks up theme colors?
- `omarchy hook display-mode-menu` — display picker works?

## Commit conventions
One commit = one layer. Types: feat, fix, refactor, style, chore, docs. Scopes: hypr, waybar, omarchy, install, scripts, assets.
