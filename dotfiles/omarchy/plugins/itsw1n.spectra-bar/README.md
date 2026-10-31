# Spectra Bar

<img width="1920" height="52" alt="image" src="https://github.com/user-attachments/assets/4594f280-a9b2-459e-aae8-bf85b4777375" />

A native [Omarchy](https://omarchy.org/) v4 bar for [Quickshell](https://quickshell.org/), inspired by the Spectra reference design and [MechaBar](https://github.com/sejjy/mechabar).

<img width="1920" height="660" alt="image" src="https://github.com/user-attachments/assets/e9523d0d-5571-4bb5-8646-b2ce1f1c3516" />

## Important highlights

- Native Omarchy widgets and panels
- Centered Arch badge with a control hub
- Sliding workspaces and responsive prism panels
- Per-module click, middle-click, right-click, and scroll actions
- CPU, memory, and temperature statistics
- Installer backups and rollback support

## Installation

Requirements: Omarchy v4 and a working Quickshell bar environment.

```bash
git clone https://github.com/itsw1n/spectra-bar.git
cd spectra-bar
./install.sh
```

The installer validates the manifest and plugin files, backs up the current Omarchy shell configuration, installs the plugin under `~/.config/omarchy/plugins/`, and selects Spectra. Restart or reload the shell if the bar does not appear immediately.

To return to the stock bar:

```bash
omarchy bar use omarchy.bar
```

The installer keeps timestamped shell backups and previous plugin copies so the previous configuration can be restored if needed.

## Configuration

Edit [`layout.json`](layout.json) to change module order and actions:

```json
{
  "id": "omarchy.monitor",
  "onScrollUp": "omarchy-brightness-display +2%",
  "onScrollDown": "omarchy-brightness-display 2%-"
}
```

For contributor setup, validation, and Omarchy compatibility notes, see [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md). For visual design constraints, see [`docs/geometry-goal.md`](docs/geometry-goal.md). Shared styling is defined in [`Theme.qml`](Theme.qml), while reusable components live in [`components/`](components/).

## License

MIT. See [`LICENSE`](LICENSE).
