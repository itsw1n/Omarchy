#!/usr/bin/env bash
read -ra fields < <(head -n 1 /proc/stat)
idle=$((fields[4] + fields[5]))
cpu_total=0
for ((i=1; i<${#fields[@]}; i++)); do ((cpu_total += fields[i])) || true; done
cache="${XDG_RUNTIME_DIR:-/tmp}/spectra-cpu-${UID}"
if [[ -r "$cache" ]]; then
  read -r old_total old_idle < "$cache"
  delta=$((cpu_total - old_total))
  if (( delta > 0 && idle >= old_idle && idle - old_idle <= delta )); then
    cpu=$(((delta - idle + old_idle) * 100 / delta))
  else
    cpu=0
  fi
else
  cpu=0
fi
printf '%s %s\n' "$cpu_total" "$idle" > "$cache"
mem=$(free -m | awk '/^Mem:/ {printf "%d", $3 * 100 / $2}')
temp='--'
for path in /sys/class/thermal/thermal_zone*/temp; do
  [[ -r "$path" ]] || continue
  read -r value < "$path"
  if (( value > 0 && value < 120000 )); then temp=$((value / 1000)); break; fi
done
printf '{"text":" %s°C    %s%%    %s%%","tooltip":"Temperature: %s°C\\nCPU: %s%%\\nRAM: %s%%"}\n' "$temp" "$cpu" "$mem" "$temp" "$cpu" "$mem"
