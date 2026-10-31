#!/usr/bin/env bash
# Move the focused window and workspace 3 to the first active external display.
set -euo pipefail
external=$(hyprctl monitors -j | jq -r '[.[] | select(.name | test("^(eDP|LVDS|DSI)-") | not)][0].name // empty')
if [[ -z "$external" ]]; then
  omarchy-notification-send 'Send to TV' 'No external display detected'
  exit 0
fi
[[ "$external" =~ ^[A-Za-z0-9._-]+$ ]] || exit 1
hyprctl dispatch 'hl.dsp.window.move({ workspace = "3", follow = false })'
hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"3\", monitor = \"$external\" })"
omarchy-notification-send 'Sent to TV' 'Window moved to workspace 3. Super+Alt+Shift+P brings it back.'
