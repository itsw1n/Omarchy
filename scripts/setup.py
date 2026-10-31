#!/usr/bin/env python3
"""Install an explicit desktop snapshot, with transactional backups."""
import argparse
import datetime
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
TOPS = ('hypr', 'omarchy', 'foot', 'fastfetch')
# Earlier backups also included these terminals; preserve explicit rollback support.
LEGACY_TOPS = ('hypr', 'omarchy', 'kitty', 'ghostty', 'alacritty', 'foot', 'fastfetch')
RETIRED = ('omarchy/hooks/theme-set',
           'omarchy/hooks/post-boot.d/10-deymn-branding',
           'omarchy/hooks/post-boot.d/20-deymn-v4-configs',
           'omarchy/hooks/post-update.d/10-deymn-branding',
           'omarchy/hooks/theme-set.d/10-deymn-branding')


def exists(path):
    return path.exists() or path.is_symlink()


def remove(path):
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.exists():
        shutil.rmtree(path)


def copy(src, dst):
    dst.parent.mkdir(parents=True, exist_ok=True)
    if src.is_symlink():
        dst.symlink_to(os.readlink(src))
    elif src.is_dir():
        shutil.copytree(src, dst, symlinks=True)
    else:
        shutil.copy2(src, dst)


def materialize(path):
    """Detach repository links before writing, including broken legacy links."""
    if path.is_symlink():
        tmp = path.with_name(path.name + '.setup-tmp')
        if exists(tmp):
            raise RuntimeError(f'Temporary path already exists: {tmp}')
        if path.is_dir():
            shutil.copytree(path, tmp, symlinks=True)
        else:
            tmp.mkdir()
        path.unlink()
        tmp.rename(path)
    path.mkdir(parents=True, exist_ok=True)


def validate():
    files = sorted(p for p in (ROOT / 'dotfiles').rglob('*') if p.is_file())
    if any(p.is_symlink() for p in files):
        raise RuntimeError('Snapshot must contain real files, not machine-specific symlinks')
    for p in files:
        if p.suffix == '.json':
            json.loads(p.read_text())
    shell = json.loads((ROOT / 'dotfiles/omarchy/shell.json').read_text())
    if shell['bar']['id'] != 'itsw1n.spectra-bar':
        raise RuntimeError('Expected the Spectra bar in shell.json')
    spectra_files(ROOT / 'spectra-bar')
    return files


def spectra_files(source):
    required = ('manifest.json', 'Bar.qml', 'BarModel.js', 'Theme.qml', 'qmldir',
                'components/ArchBadge.qml', 'components/ArchControlHub.qml',
                'components/HubControlRow.qml', 'components/PrismPanel.qml',
                'components/PrismConnector.qml', 'components/SpectraWorkspaces.qml',
                'assets/arch.svg', 'scripts/stats.sh', 'LICENSE')
    for name in required:
        if not (source / name).is_file():
            raise RuntimeError(f'Missing Spectra file: {source / name}. '
                               'Run git submodule update --init --recursive.')
    manifest = json.loads((source / 'manifest.json').read_text())
    if manifest['id'] != 'itsw1n.spectra-bar':
        raise RuntimeError(f'Expected Spectra plugin at {source}')
    files = [source / name for name in
             ('manifest.json', 'Bar.qml', 'BarModel.js', 'Theme.qml', 'qmldir', 'LICENSE')]
    for directory in ('components', 'assets', 'scripts'):
        files.extend(p for p in (source / directory).rglob('*') if p.is_file())
    if any(p.is_symlink() for p in files):
        raise RuntimeError('Spectra runtime files must not be symlinks')
    return sorted(files)


def backup(home, config, roots=TOPS):
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    dest = home / '.local/state/omarchy-setup/backups' / stamp
    dest.mkdir(parents=True, mode=0o700)
    present = []
    for name in roots:
        if exists(config / name):
            copy(config / name, dest / 'config' / name)
            present.append(name)
    (dest / 'manifest.json').write_text(json.dumps({'present': present, 'tops': roots}))
    return dest


def backup_manifest(dest):
    manifest = json.loads((dest / 'manifest.json').read_text())
    if tuple(manifest['tops']) not in (TOPS, LEGACY_TOPS) or not set(manifest['present']).issubset(manifest['tops']):
        raise RuntimeError('Invalid backup manifest')
    return manifest


def restore(dest, config):
    manifest = backup_manifest(dest)
    for name in manifest['tops']:
        remove(config / name)
        if name in manifest['present']:
            copy(dest / 'config' / name, config / name)


def run(*args):
    subprocess.run(args, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dry-run', action='store_true', help='Validate and list changes without writing')
    parser.add_argument('--home', type=Path, default=Path.home(), help='Alternate home for offline installation/testing')
    parser.add_argument('--monitors', choices=['preserve', 'portable', 'deymn'], default='preserve',
                        help='Keep existing monitors; use portable on a new machine (default)')
    parser.add_argument('--no-apply', action='store_true', help='Copy only; apply theme/session at next login')
    parser.add_argument('--restore', type=Path, help='Restore an installer backup (backs up current config first)')
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--spectra-dev', type=Path, metavar='CHECKOUT',
                      help='Link the installed plugin to a local Spectra checkout')
    mode.add_argument('--spectra-copy', action='store_true',
                      help='Replace a development link with a copy of the pinned submodule')
    args = parser.parse_args()
    home = args.home.expanduser().resolve()
    config = home / '.config'
    live = home == Path.home().resolve()
    if os.geteuid() == 0 and live:
        parser.error('Run as your desktop user, not root')
    if live and not args.restore:
        version = subprocess.check_output(['omarchy', 'version'], text=True).strip()
        if not version.startswith('4.'):
            parser.error(f'Requires Omarchy 4.x; found {version}')
        for cmd in ('jq', 'hyprctl', 'omarchy-shell'):
            if not shutil.which(cmd):
                parser.error(f'Required command is missing: {cmd}')
    if args.restore:
        dest = args.restore.expanduser().resolve()
        manifest = backup_manifest(dest)
        if args.dry_run:
            print(f'Would restore desktop configuration from {dest}')
            return
        current = backup(home, config, roots=tuple(manifest['tops']))
        restore(dest, config)
        print(f'Restored {dest}. Previous configuration saved at {current}. Log in again to apply.')
        return
    files = validate()
    plugin_dst = config / 'omarchy/plugins/itsw1n.spectra-bar'
    link_source = args.spectra_dev.expanduser().resolve() if args.spectra_dev else None
    if link_source is None and plugin_dst.is_symlink() and not args.spectra_copy:
        link_source = plugin_dst.resolve()
    if link_source is not None and (link_source == plugin_dst or plugin_dst in link_source.parents):
        parser.error('Spectra development checkout must be outside its installation directory')
    plugin_source = link_source or ROOT / 'spectra-bar'
    plugin_files = spectra_files(plugin_source)
    print(f'Spectra: {"development link to " + str(link_source) if link_source else "copy of pinned submodule"}')
    print(f'Destination: {config}\nManaged files: {len(files)}; monitors: {args.monitors}')
    print('Copies Spectra, shell layout/idle, Lua settings, Foot, branding, wallpaper and hooks.')
    print('Archives/backups, credentials, network profiles and legacy/ are not installed.')
    if args.dry_run:
        for p in files:
            print(p.relative_to(ROOT / 'dotfiles'))
        return
    config.mkdir(parents=True, exist_ok=True)
    saved = backup(home, config)
    print(f'Backup: {saved}', flush=True)
    try:
        # Detach symlinked directories so copying cannot edit the source repository.
        for name in TOPS:
            materialize(config / name)
        for p in files:
            rel = p.relative_to(ROOT / 'dotfiles')
            if str(rel) == 'hypr/monitors.lua':
                continue
            dst = config / rel
            parent = config
            for part in rel.parts[:-1]:
                parent = parent / part
                materialize(parent)
            remove(dst)
            shutil.copy2(p, dst)
        materialize(plugin_dst.parent)
        if link_source is not None:
            if not plugin_dst.is_symlink() or plugin_dst.resolve() != link_source:
                remove(plugin_dst)
                plugin_dst.symlink_to(link_source, target_is_directory=True)
        else:
            remove(plugin_dst)
            for source in plugin_files:
                dst = plugin_dst / source.relative_to(plugin_source)
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, dst)
        monitor = config / 'hypr/monitors.lua'
        if args.monitors != 'preserve' or not monitor.exists():
            profile = 'deymn' if args.monitors == 'deymn' else 'portable'
            remove(monitor)
            shutil.copy2(ROOT / f'profiles/{profile}-monitors.lua', monitor)
        for rel in RETIRED:
            path = config / rel
            parent = config
            for part in Path(rel).parts[:-1]:
                parent = parent / part
                materialize(parent)
            remove(path)
        # Seed personal wallpaper for all installed themes without duplicate repo assets.
        prefs = json.loads((ROOT / 'preferences.json').read_text())
        themes = {'matte-black', prefs['theme']}
        for base in (Path('/usr/share/omarchy/themes'), config / 'omarchy/themes'):
            if base.exists():
                themes.update(p.name for p in base.iterdir() if p.is_dir() and (p / 'colors.toml').exists())
        for theme in themes:
            dst = config / 'omarchy/backgrounds' / theme
            materialize(dst)
            shutil.copy2(config / 'omarchy/wallpapers' / prefs['wallpaper'], dst / prefs['wallpaper'])
        if live and not args.no_apply:
            # Theme application updates generated state; source files stay in ~/.config.
            run('omarchy', 'theme', 'set', prefs['theme'])
            wallpaper = config / 'omarchy/backgrounds' / prefs['theme'] / prefs['wallpaper']
            run('omarchy-theme-bg-set', str(wallpaper))
            run('hyprctl', 'reload')
            errors = subprocess.check_output(['hyprctl', 'configerrors'], text=True).strip()
            if errors and errors != 'ok':
                raise RuntimeError(errors)
            run('omarchy-shell', 'shell', 'rescanPlugins')
    except Exception:
        restore(saved, config)
        if live and not args.no_apply:
            subprocess.run(['hyprctl', 'reload'], check=False)
        print(f'Configuration restored after failure. Backup: {saved}', file=sys.stderr)
        raise
    print('Installed. ' + ('Development checkout must stay in place.' if link_source else 'Installed files are independent copies.') + ' Log in again if installed without a live session.')
    print('Optional applications: see packages.txt. Boot/login Plymouth branding stays manual; see README.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
