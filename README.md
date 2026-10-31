# DEYMN Omarchy Setup

A portable snapshot of my Omarchy **4.x** desktop, including the **Spectra bar**
(the native Quickshell replacement for my old Waybar), keyboard/input settings,
DEYMN screensaver, personal wallpaper, idle times and Foot terminal settings.
Tested on Omarchy 4.0.6 / Hyprland 0.56.2.

## Install on another machine

Install Omarchy first and log into its desktop. Then:

```bash
git clone --recurse-submodules https://github.com/itsw1n/Omarchy.git ~/Files/omarchy-setup
cd ~/Files/omarchy-setup
./install.sh --dry-run
./install.sh
```

Spectra is saved as a Git submodule at `dotfiles/omarchy/plugins/itsw1n.spectra-bar/`, pinned to a tested commit.
For an existing clone, run `git submodule update --init --recursive` first.
Python 3, jq, Hyprland and the Omarchy 4 shell are required. Normal installation
copies desktop settings and Spectra runtime files; the source clone can then move.
No OS reinstall or administrator privileges are required.

Existing monitor settings are preserved by default. A new machine uses automatic
connector detection, preferred resolution, automatic placement and scale 1.
To explicitly replace its monitor configuration:

```bash
./install.sh --monitors portable  # automatic layout
./install.sh --monitors deymn     # my 1080p laptop at 1.25x and HDMI TV at 1x
```

The laptop/TV profile is hardware-specific. Adjust the scale in
`~/.config/hypr/monitors.lua` for a different screen. Use `--no-apply` to copy
without changing the running theme/session. `--home /tmp/example-home` installs
offline into a separate home directory without running desktop commands.

The installer selects the saved theme and wallpaper, validates Hyprland after
reload and rescans shell plugins. Spectra and shell configuration hot-reload.
Log in again if installing outside a running desktop. Use `packages.txt` for the
font names and optional applications; applications and accounts are separate
from this desktop snapshot. OpenCode and Typora shortcuts require those apps. The OpenCode shortcut launches
an installed Mise version in offline mode, with system/native installations as
fallbacks; it never installs or updates OpenCode during startup.
The default terminal selection remains the destination machine's preference.

## What is saved

- `dotfiles/hypr/`: Lua overrides, display picker and TV scripts, night-light and portal configuration.
- `dotfiles/omarchy/shell.json`: Spectra selection, widgets/actions, 150-second screensaver and 300-second lock.
- `dotfiles/omarchy/plugins/itsw1n.spectra-bar/`: Git submodule pointing to the saved Spectra version; its runtime and MIT license are copied during installation.
- `dotfiles/omarchy/branding/` and `wallpapers/`: personal artwork.
- `dotfiles/omarchy/hooks/`: portable hooks with no dependency on this clone.
- `dotfiles/foot/`: settings for Foot, my current terminal. Other terminal configurations are not captured or installed.
- `dotfiles/fastfetch/`: my system-info layout and DEYMN ASCII logo.
- `profiles/`: automatic and original-machine display profiles.
- `preferences.json`: theme and wallpaper selection.

The installer merges these files into user configuration. Unrelated plugins,
themes and hooks are preserved. It removes only obsolete DEYMN hooks that
patched branding or overwrote configs on every boot. Existing repository-linked
configuration directories are detached before writing.

## Backups and rollback

Every install backs up the affected configuration roots (`hypr`, `omarchy`,
`foot`, and `fastfetch`) under `~/.local/state/omarchy-setup/backups/<timestamp>/`.
If copying or live validation fails, those configuration roots are restored.
Theme application can also change generated theme state and application colors;
that state is not part of configuration rollback. Reapply the previous theme if needed.

To restore a previous configuration explicitly:

```bash
./install.sh --restore ~/.local/state/omarchy-setup/backups/TIMESTAMP
```

Restoration first backs up the current configuration and then restores those
four configuration roots, including files added since the backup. Log in again
and reapply your previous theme afterward. Older seven-directory backups remain
supported; explicitly restoring one also restores the other terminal settings it
contains. Backups are local and never committed.

## Update this snapshot after changing the desktop

```bash
python3 scripts/capture.py
./install.sh --dry-run
git diff
```

Capture reads an explicit list of desktop settings. It does not copy Spectra or
change the saved submodule version.
It also saves the active wallpaper, theme name and locally authored theme overlays.
It keeps a backup of the previous snapshot under
`~/.local/state/omarchy-setup/captures/`. It does not collect credentials, Wi-Fi
profiles, browser data, applications, or an entire home directory.

## Spectra development

To use your separate Spectra checkout directly:

```bash
./install.sh --spectra-dev ~/Files/spectra-bar
```

Your running bar then uses that folder through a symlink. Edits affect the desktop;
the folder must stay in place. Repeat installs preserve the link.
To return to a standalone copy of the saved version, run `./install.sh --spectra-copy`.

Spectra edits do not automatically update this repo's saved version.
See [the short update workflow](docs/spectra-workflow.md).

## Removed old setup

The obsolete v3 installer, Waybar files, Hyprlock/Hypridle configuration, upgrade
staging and automatic Plymouth scripts have been removed from this working tree.
They were backed up locally outside the repository before removal. The last
committed legacy setup is also preserved in the
[v1.0.0-omarchy3 release](https://github.com/itsw1n/Omarchy/releases/tag/v1.0.0-omarchy3). Stock Aether shader symlinks have
been removed from the snapshot; they pointed to package-owned system files and
are not required by this desktop. The installed shader package/files are untouched.

Boot/login Plymouth branding is separate from the current Quickshell lock screen
and remains a manual system customization. Personal artwork remains in assets/.
Night light remains off by default, matching this desktop. No machine-specific
Wi-Fi driver tweaks or upgrade preparation scripts are applied.

See CLEANUP.md for the checks and retained files.
