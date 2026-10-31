# Spectra development and saved setup versions

Status: **planned workflow; not enabled yet**. Today, omarchy-setup contains a
copied Spectra runtime under `dotfiles/omarchy/plugins/itsw1n.spectra-bar/`, and
the installer copies it into the desktop plugin directory. No submodule or
local development symlink has been configured by this documentation change.

## Intended arrangement

Spectra is developed in its own repository, https://github.com/itsw1n/spectra-bar.
Omarchy Setup records a tested Spectra commit using a Git submodule at
`spectra-bar/` rather than maintaining a second editable copy of the bar.

On the development machine, the installed plugin would be a directory symlink:

```text
~/.config/omarchy/plugins/itsw1n.spectra-bar
  -> ~/Files/spectra-bar
```

Editing the original Spectra checkout then changes the files read by the running
bar. Omarchy's shell watches plugin code and reloads it; a shell plugin rescan
may be needed if a new file does not appear immediately. The target checkout
must remain at that path. Uncommitted edits can affect the live desktop too.

The submodule inside Omarchy Setup is a separate Git checkout of the same project,
not an automatically synchronized mirror of `~/Files/spectra-bar`. Omarchy Setup
stores its repository URL and the exact commit selected for future installations.

On another machine, the installer would copy runtime files from that saved
submodule checkout into the plugin directory. The installed desktop would not
depend on keeping either source checkout in place.

## What updates automatically?

| Action | Running desktop with development symlink | Saved version in Omarchy Setup |
| --- | --- | --- |
| Edit files in the original Spectra checkout | Reads those edits | Unchanged |
| Commit and push Spectra | Already reads those files | Unchanged |
| Select a newer submodule commit | Unchanged; still uses original checkout | Changed locally |
| Commit and push the updated submodule reference | Unchanged | Available to future clones/installations |

## Updating the saved version after implementation

These commands assume the submodule has already been added at `spectra-bar/`.
They do not work with the current copied-file arrangement.

First test your Spectra changes, then commit and push them in the original
Spectra repository. From Omarchy Setup, select that exact published commit:

```bash
cd ~/Files/omarchy-setup
spectra_commit=$(git -C ~/Files/spectra-bar rev-parse HEAD)
git submodule update --init spectra-bar
git -C spectra-bar fetch origin
git -C spectra-bar checkout --detach "$spectra_commit"
git diff --submodule=log -- spectra-bar
# Test the selected version before saving the setup update.
git add spectra-bar
git commit -m "chore(bar): update tested Spectra version"
git push origin main
```

The original Spectra working tree should be clean when choosing a commit:
uncommitted edits are not included in the submodule reference. Push the Spectra
commit before pushing Omarchy Setup, otherwise another machine may be unable to
fetch the referenced version.

Alternatively, `git submodule update --remote spectra-bar` selects the configured
upstream branch tip. Review and test that version before committing the reference;
it can differ from the commit tested in your original development checkout.

## Cloning and pulling after implementation

A new machine would initialize the submodule when cloning:

```bash
git clone --recurse-submodules https://github.com/itsw1n/Omarchy.git ~/Files/omarchy-setup
```

An existing clone would obtain the version saved by the setup repository with:

```bash
git pull --ff-only
git submodule update --init --recursive
```

This fetches the saved commit. It does not automatically select the newest
Spectra version. Updating a checkout also does not update an independently
installed copy until the installer is run again.

## Implementation work still needed

- Add the submodule and select a tested, published Spectra commit.
- Replace the copied plugin snapshot with runtime installation from the submodule.
- Keep the Spectra license, required assets, scripts and components in installed copies.
- Update capture to save desktop settings without copying the bar source back into dotfiles.
- Update installer validation/tests and document submodule initialization requirements.
- Back up the installed plugin before enabling the local development symlink.
- Make repeat installs preserve the development symlink or require an explicit switch
  back to an independent installed copy. The present installer replaces plugin files
  and is not yet compatible with that development symlink.

Until that migration is implemented, use the existing documented capture command
to refresh the bundled Spectra copy. Do not create the development symlink and
assume the present installer will preserve it.
