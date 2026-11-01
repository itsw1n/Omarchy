# Spectra installation and updates

| Repository | Purpose |
| --- | --- |
| [Spectra Bar](https://github.com/itsw1n/spectra-bar) | Owns the bar's code, appearance, and behavior. |
| [Omarchy Setup](https://github.com/itsw1n/Omarchy) | Restores desktop settings and installs a saved Spectra version. |

Spectra Bar can be installed independently on Omarchy v4. This setup integrates
it as the default bar. The instructions for connecting the two repositories
belong here; standalone Spectra installation is documented in its own README.

Make bar changes in the separate `spectra-bar` repository. Omarchy Setup saves
one Spectra commit (a recorded code version) through a **submodule**, Git's way
of linking another repository. It is stored at
`dotfiles/omarchy/plugins/itsw1n.spectra-bar/`. Pushing changes to Spectra does
not automatically update that saved version.

## Optional: edit Spectra directly

For bar development, clone Spectra separately, then run from the `omarchy-setup`
folder:

```bash
./install.sh --spectra-dev ~/Files/spectra-bar
```

This creates a symlink (a filesystem shortcut), so the running bar reads code
from the separate Spectra folder. Keep that folder in place. Reload the shell
with `omarchy restart shell` if edits do not appear. Repeat installs
preserve the link; `./install.sh --spectra-copy` switches to an independent copy
of the version saved by this repo. Existing files are backed up first.

## After publishing Spectra changes (maintainers)

These steps are for maintainers of Omarchy Setup or a personal fork. Installing
the setup does not require them. Publishing requires permission to push to the
repositories involved.

First test, commit, and push bar changes in the **Spectra Bar repository**.
Once those changes are published, run the following in the **Omarchy Setup
repository**:

```bash
cd ~/Files/omarchy-setup
git submodule update --init --remote dotfiles/omarchy/plugins/itsw1n.spectra-bar
git diff --submodule=log -- dotfiles/omarchy/plugins/itsw1n.spectra-bar
# Check the diff shows the Spectra commit you want before continuing.
git add dotfiles/omarchy/plugins/itsw1n.spectra-bar
git commit -m "chore(bar): update Spectra"
git push
```

The update command downloads and selects the latest published Spectra commit.
The diff shows which code versions changed. The commit and push save that selection in Omarchy
Setup so other machines receive it too. These steps do not reinstall the bar
or change your separate Spectra development checkout.

For a specific tested commit instead of the latest version, replace the
`git submodule update --init --remote ...` step with these commands, then review,
commit, and push as above:

```bash
git submodule update --init dotfiles/omarchy/plugins/itsw1n.spectra-bar
git -C dotfiles/omarchy/plugins/itsw1n.spectra-bar fetch origin
git -C dotfiles/omarchy/plugins/itsw1n.spectra-bar checkout --detach COMMIT_HASH
```

Replace `COMMIT_HASH` with the published Spectra commit you tested.

Changes in the original checkout do **not** automatically update this saved
reference. `python3 scripts/capture.py` saves desktop settings only.

## Install on another machine

Install Omarchy 4 first and log into its desktop. Omarchy Setup installs the
saved Spectra version, so no separate Spectra clone or installer is needed:

```bash
git clone --recurse-submodules https://github.com/itsw1n/Omarchy.git ~/Files/omarchy-setup
cd ~/Files/omarchy-setup
./install.sh --dry-run
./install.sh
```

The dry run previews the installation. The final command applies the settings.

## Update an existing installation

Run these commands to receive the settings and Spectra version selected by the
setup maintainer:

```bash
cd ~/Files/omarchy-setup
git pull --ff-only
git submodule update --init --recursive
./install.sh --dry-run
./install.sh
```

Use `--remote` only when deliberately selecting a newer Spectra version for
Omarchy Setup. Regular installations use the saved commit. Normal installation
copies the saved runtime; it does not require a permanent development checkout.
