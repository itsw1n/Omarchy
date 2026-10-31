#!/usr/bin/env python3
"""Omarchy 4 display picker; query inactive outputs so Internal only is reversible."""
import json
import re
import subprocess
import sys


def run(*args):
    result = subprocess.run(args, check=True, text=True, capture_output=True)
    if args[0] == 'hyprctl' and result.stdout.strip() not in ('', 'ok'):
        raise RuntimeError(result.stdout.strip())
    return result.stdout.strip()


def notify(message):
    subprocess.run(['omarchy-notification-send', 'Display mode', message], check=False)


def main():
    monitors = json.loads(subprocess.check_output(['hyprctl', 'monitors', 'all', '-j'], text=True))
    internal = next((m['name'] for m in monitors if re.match(r'^(eDP|LVDS|DSI)-', m['name'])), None)
    external = [m['name'] for m in monitors if not re.match(r'^(eDP|LVDS|DSI)-', m['name'])]
    if not internal or not external:
        notify('Connect an external display to use display modes')
        return
    if any(not re.fullmatch(r'[A-Za-z0-9._-]+', name) for name in [internal, *external]):
        raise RuntimeError('Invalid monitor connector name')
    choices = ['Duplicate', 'Extend', 'External only', 'Internal only']
    if len(sys.argv) > 1:
        choice = sys.argv[1]
    else:
        menu = subprocess.run(['omarchy-menu-select', 'Display mode', *choices], text=True, capture_output=True)
        if menu.returncode or not menu.stdout.strip():
            return
        choice = menu.stdout.strip()
    if choice not in choices:
        raise RuntimeError('Unknown display mode')
    run('omarchy-hyprland-monitor-internal-mirror', 'off')
    run('omarchy-hyprland-monitor-internal', 'on')
    # Restore configured positions before changing temporary runtime output states.
    run('hyprctl', 'reload')
    for name in external:
        run('hyprctl', 'eval', f'hl.monitor({{ output = "{name}", disabled = false }})')
    if choice == 'Duplicate':
        run('omarchy-hyprland-monitor-internal-mirror', 'on')
    elif choice == 'External only':
        run('omarchy-hyprland-monitor-internal', 'off')
    elif choice == 'Internal only':
        for name in external:
            run('hyprctl', 'eval', f'hl.monitor({{ output = "{name}", disabled = true }})')
    notify(choice)


if __name__ == '__main__':
    try:
        main()
    except (subprocess.CalledProcessError, RuntimeError, ValueError) as error:
        notify(str(error))
        sys.exit(1)
