# Cleanup log — 2026-10-31

Goal: install the current Omarchy 4 desktop, including Spectra, on another machine.

Verified before removing unused repository files:

- Current Hyprland loads Lua overrides and reports no configuration errors.
- The active shell configuration selects itsw1n.spectra-bar.
- No references to the legacy directory or old repository path were found in the
  current Hyprland config, shell.json, hooks, UWSM config or user service files.
- No Waybar, Hypridle or Hyprlock processes were running during the check.
- Hyprland reports decoration:screen_shader as empty and unset.
- Current ~/.config/hypr is an independent directory; removing repository shader
  links cannot remove its installed shader files.

Removed from the repository working tree:

- legacy/v3/: old installer, Waybar and its ZIP, old lock/idle configs, upgrade
  preparation/staging and obsolete branding/config-overwrite hooks/scripts.
- dotfiles/hypr/shaders/: stock symlinks to /usr/share/aether/shaders/.

A local backup was made under ~/.local/state/omarchy-setup/backups/unused-repo-files-*.
No installed shader package, system file, application or terminal config was removed.

Retained deliberately:

- Spectra, shell layout/actions, branding, wallpaper, Lua overrides and display scripts.
- Foot settings, matching the current default terminal. After the user confirmed
  the other terminals are unused, Alacritty, Ghostty and Kitty configs were removed
  from the repository and capture list. Their installed apps/settings are untouched.
- Original artwork in assets/: it is personal source material, not obsolete code.
- Separate portable and original-machine monitor profiles.

Validation: installer tests cover fresh/repeat installs, monitor preservation,
symlink detachment, rollback and recovery from a simulated copy failure. Hardware
TV/mirroring behavior still needs verification with an external display attached.

The legacy baseline is preserved in the published v1.0.0-omarchy3 tag/release.
The subsequent v4 migration is recorded in separate commits; no v4 release has
been created as part of this cleanup.

Spectra now uses a pinned Git submodule at spectra-bar/ instead of copied source.
The local desktop plugin links to ~/Files/spectra-bar for development. Normal
installs copy the saved submodule runtime; repeat installs preserve development
links unless --spectra-copy is requested. Desktop capture does not copy Spectra.
