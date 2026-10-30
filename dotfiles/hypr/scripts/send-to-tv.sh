#!/bin/bash
# Send the focused window to workspace 3 on the external display (TV).
set -euo pipefail

EXTERNAL=$(hyprctl monitors -j | jq -r '.[] | select(.name | test("^(eDP|LVDS|DSI)-") | not) | .name' | head -n 1)
if [[ -z "$EXTERNAL" ]]; then
  notify-send -u low "󰍹 Sent to TV" "No external display detected"
  exit 0
fi

hyprctl dispatch movetoworkspacesilent 3 >/dev/null
hyprctl dispatch moveworkspacetomonitor 3 "$EXTERNAL" >/dev/null 2>&1 || true
notify-send -u low "󰍹 Sent to TV" "Window → workspace 3 ($EXTERNAL). Press SUPER+3 to view, SUPER+ALT+SHIFT+P to bring back"
