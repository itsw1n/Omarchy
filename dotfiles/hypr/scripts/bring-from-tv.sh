#!/usr/bin/env bash
# Bring the last-focused window on TV workspace 3 back to this workspace.
set -euo pipefail
active=$(hyprctl activeworkspace -j | jq -r '.id')
[[ "$active" =~ ^[0-9]+$ ]] || exit 1
if [[ "$active" == 3 ]]; then
  hyprctl dispatch 'hl.dsp.window.move({ workspace = "1", follow = true })'
  exit 0
fi
window=$(hyprctl clients -j | jq -r '[.[] | select(.workspace.id == 3)] | sort_by(.focusHistoryID // 999999) | .[0].address // empty')
if [[ -z "$window" ]]; then
  omarchy-notification-send 'Bring from TV' 'No window on workspace 3'
  exit 0
fi
[[ "$window" =~ ^0x[0-9a-fA-F]+$ ]] || exit 1
hyprctl dispatch "hl.dsp.window.move({ window = \"address:$window\", workspace = \"$active\", follow = false })"
omarchy-notification-send 'Back on laptop' "Window moved to workspace $active"
