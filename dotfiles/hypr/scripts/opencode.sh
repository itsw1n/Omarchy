#!/usr/bin/env bash
# Start an already installed OpenCode. Installation/upgrades are separate actions.
set -euo pipefail
if command -v mise >/dev/null 2>&1; then
  executable=$(MISE_OFFLINE=1 mise which opencode 2>/dev/null) || executable=""
  if [[ -n "$executable" && -x "$executable" ]]; then
    exec "$executable" "$@"
  fi
fi
for executable in /usr/bin/opencode "$HOME/.opencode/bin/opencode"; do
  if [[ -x "$executable" ]]; then
    exec "$executable" "$@"
  fi
done
message='OpenCode is not installed. Install it separately, then press Super+Shift+C again.'
command -v omarchy-notification-send >/dev/null 2>&1 && omarchy-notification-send 'OpenCode' "$message" || true
printf '%s\n' "$message" >&2
exit 127
