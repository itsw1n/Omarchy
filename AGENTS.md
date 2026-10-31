# Omarchy Setup — assistant guide

This repository targets an already installed Omarchy 4.x desktop.
Read README.md and scripts/setup.py before changing installation behavior.
Use the Omarchy skill for live configuration work. Never edit /usr/share/omarchy.

- dotfiles/ is an explicit, portable snapshot. Install copies, never symlinks.
- Spectra is vendored under dotfiles/omarchy/plugins/itsw1n.spectra-bar; preserve its MIT license.
- Obsolete v3 files were removed after an external backup. Do not reintroduce the v3 installer, Waybar or automatic privileged branding scripts.
- Preserve destination monitor settings by default; use profiles/ for portable or original-machine layouts.
- Back up before replacing configurations. Keep dry-run and rollback working.
- Do not collect credentials, browser profiles, private keys or full home directories.
- New captured files belong in scripts/capture.py's explicit allowlist.
- Never apply hardware driver settings or install/reinstall the OS from this repo.
- Run tests/test_setup.py, Python/shell syntax checks and install.sh --dry-run after installer changes.
- After live Hyprland changes, run hyprctl reload and hyprctl configerrors.

Commit types: feat, fix, refactor, style, chore, docs. Keep commits focused.
