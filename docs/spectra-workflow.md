# Spectra workflow

**Spectra owns the bar code. Omarchy Setup saves which Spectra version to install.**
The saved version is a Git submodule at `spectra-bar/`.

## On your development machine

From Omarchy Setup:

```bash
./install.sh --spectra-dev ~/Files/spectra-bar
```

This links the installed plugin to your separate Spectra checkout. Editing that
checkout updates the running bar. Keep the folder in place. Repeat installs
preserve the link; `./install.sh --spectra-copy` switches to an independent copy
of the version saved by this repo. Existing files are backed up first.

## Save a newer Spectra version

First test, commit and push your changes in the original Spectra repo. Then:

```bash
cd ~/Files/omarchy-setup
git submodule update --init --remote spectra-bar
git diff --submodule=log -- spectra-bar
```

That selects the latest published upstream commit. Check it is the version you
want, then save the reference:

```bash
git add spectra-bar
git commit -m "chore(bar): update Spectra"
```

For a specific tested commit instead, fetch and select it before `git add`:

```bash
git -C spectra-bar fetch origin
git -C spectra-bar checkout --detach COMMIT_HASH
```

Changes in the original checkout do **not** automatically update this saved
reference. `python3 scripts/capture.py` saves desktop settings only.

## On another machine

```bash
git clone --recurse-submodules https://github.com/itsw1n/Omarchy.git ~/Files/omarchy-setup
cd ~/Files/omarchy-setup
./install.sh
```

For an existing clone, run `git pull --ff-only` followed by
`git submodule update --init --recursive`, then install again. Normal installation
copies the saved runtime; it does not require a permanent development checkout.
