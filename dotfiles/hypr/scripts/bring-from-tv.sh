#!/bin/bash
# Bring the most recent window from TV workspace 3 to the current workspace.
set -euo pipefail

ACTIVE=$(hyprctl activeworkspace -j | jq -r '.id')

if [[ "$ACTIVE" == "3" ]]; then
  hyprctl dispatch movetoworkspace 1 >/dev/null
  notify-send -u low "󰍹 Back on laptop" "Window from TV → workspace 1"
  exit 0
fi

WIN=$(hyprctl clients -j | jq -r '.[] | select(.workspace.id == 3) | .address' | tail -n 1)
if [[ -z "$WIN" ]]; then
  notify-send -u low "󰍹 Back on laptop" "No window on workspace 3"
  exit 0
fi

hyprctl dispatch movetoworkspacesilent "$ACTIVE,address:$WIN" >/dev/null
notify-send -u low "󰍹 Back on laptop" "Window from TV → workspace $ACTIVE"
