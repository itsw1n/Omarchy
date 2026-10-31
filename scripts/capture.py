#!/usr/bin/env python3
"""Refresh the explicit desktop snapshot from the current user; no credentials."""
import argparse
import datetime
import json
from pathlib import Path
import shutil
import tarfile

ROOT = Path(__file__).resolve().parents[1]
FILES = (
    'hypr/hyprland.lua', 'hypr/bindings.lua', 'hypr/input.lua', 'hypr/looknfeel.lua',
    'hypr/scripts/display-mode.py', 'hypr/scripts/send-to-tv.sh', 'hypr/scripts/bring-from-tv.sh',
    'hypr/autostart.lua', 'hypr/hyprsunset.conf', 'hypr/xdph.conf',
    'omarchy/shell.json', 'omarchy/branding/screensaver.txt', 'omarchy/branding/logo_vertical',
    'omarchy/hooks/display-mode-menu', 'omarchy/hooks/theme-set.d/20-personal-wallpapers',
    'fastfetch/config.jsonc', 'foot/foot.ini',
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--spectra-source', type=Path, help='Use a Spectra development checkout instead of the installed plugin')
    args = parser.parse_args()
    config = Path.home() / '.config'
    plugin = args.spectra_source or config / 'omarchy/plugins/itsw1n.spectra-bar'
    manifest = json.loads((plugin / 'manifest.json').read_text())
    if manifest['id'] != 'itsw1n.spectra-bar':
        parser.error('Expected the Spectra bar plugin')
    # Validate all required inputs before replacing any snapshot files.
    required = [config / p for p in FILES] + [config / 'hypr/monitors.lua']
    required += [plugin / p for p in ('Bar.qml', 'BarModel.js', 'Theme.qml', 'qmldir', 'scripts/stats.sh')]
    for path in required:
        if not path.is_file():
            parser.error(f'Missing required source: {path}')
    dest = Path.home() / '.local/state/omarchy-setup/captures'
    dest.mkdir(parents=True, exist_ok=True)
    archive = dest / (datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f') + '.tar.gz')
    with tarfile.open(archive, 'w:gz') as tar:
        for name in ('dotfiles', 'profiles', 'preferences.json'):
            tar.add(ROOT / name, arcname=name)
    for name in FILES:
        source, target = config / name, ROOT / 'dotfiles' / name
        target.parent.mkdir(parents=True, exist_ok=True)
        if source.resolve() != target.resolve():
            shutil.copy2(source, target)
    target = ROOT / 'dotfiles/omarchy/plugins/itsw1n.spectra-bar'
    for name in ('Bar.qml', 'BarModel.js', 'Theme.qml', 'qmldir', 'manifest.json', 'LICENSE', 'README.md', 'layout.json'):
        if (plugin / name).is_file():
            shutil.copy2(plugin / name, target / name)
    for name in ('components', 'assets', 'scripts'):
        shutil.rmtree(target / name)
        shutil.copytree(plugin / name, target / name, symlinks=False)
    shutil.copy2(config / 'hypr/monitors.lua', ROOT / 'profiles/deymn-monitors.lua')
    theme = (Path.home() / '.local/state/omarchy/current/theme.name').read_text().strip()
    prefs = {'theme': theme, 'wallpaper': 'wallmain.png'}
    wallpaper = Path.home() / '.local/state/omarchy/current/background'
    if wallpaper.is_file():
        prefs['wallpaper'] = 'current' + wallpaper.resolve().suffix.lower()
        shutil.copy2(wallpaper, ROOT / 'dotfiles/omarchy/wallpapers' / prefs['wallpaper'])
    (ROOT / 'preferences.json').write_text(json.dumps(prefs, indent=2) + '\n')
    # Theme overlays are local authoring files; omit .git and backup files.
    themes = config / 'omarchy/themes'
    for directory in themes.iterdir() if themes.exists() else []:
        if directory.is_dir() and (directory / 'colors.toml').is_file():
            target_theme = ROOT / 'dotfiles/omarchy/themes' / directory.name
            if target_theme.exists():
                shutil.rmtree(target_theme)
            shutil.copytree(directory, target_theme, symlinks=False,
                            ignore=shutil.ignore_patterns('.git', '*.bak', '*.sample', '*~'))
    print(f'Captured current desktop and Spectra. Previous snapshot: {archive}')
    print('Review git diff before committing. Apps, accounts, passwords and hardware state are not captured.')


if __name__ == '__main__':
    main()
