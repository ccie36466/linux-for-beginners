#!/usr/bin/env bash
# health-report.sh - one-page server health report
# Usage: health-report.sh [output-file]
set -uo pipefail

out="${1:-/dev/stdout}"
warn=0
flag() { echo "  !! $1"; warn=$((warn + 1)); }

{
echo "=== Health report: $(hostname) - $(date '+%F %T') ==="
echo
echo "Uptime:   $(uptime -p)"
echo "Load:     $(cut -d' ' -f1-3 /proc/loadavg) (cores: $(nproc))"
load1=$(cut -d' ' -f1 /proc/loadavg)
if awk -v l="$load1" -v c="$(nproc)" 'BEGIN {exit !(l > c)}'; then
    flag "Load is higher than the number of cores"
fi

mem_avail=$(free -m | awk '/^Mem:/ {print $7}')
mem_total=$(free -m | awk '/^Mem:/ {print $2}')
echo "Memory:   ${mem_avail} MB available of ${mem_total} MB"
(( mem_avail * 100 / mem_total < 10 )) \
    && flag "Less than 10% memory available"

echo
echo "Disk usage:"
while read -r fs pct mnt; do
    echo "  $mnt ($fs): $pct"
    (( ${pct%\%} >= 85 )) && flag "$mnt is ${pct} full"
done < <(df -P -x tmpfs -x devtmpfs -x squashfs -x overlay \
          | awk 'NR>1 {print $1, $5, $6}')

echo
failed=$(systemctl --failed --no-legend --plain 2>/dev/null \
         | awk '{print $1}')
if [[ -n "$failed" ]]; then
    echo "Failed services:"
    while read -r svc; do echo "  $svc"; done <<< "$failed"
    flag "Some services have failed"
else
    echo "Failed services: none"
fi

updates=$(apt list --upgradable 2>/dev/null | grep -c upgradable || true)
echo "Pending updates: $updates"
[[ -f /var/run/reboot-required ]] && flag "A reboot is required"

ssh_fail=$(journalctl -u ssh --since "24 hours ago" 2>/dev/null \
    | grep -cE "Failed password|Invalid user" || true)
echo "Failed SSH logins (24h): $ssh_fail"

echo
if (( warn == 0 )); then
    echo "RESULT: OK"
else
    echo "RESULT: $warn warning(s)"
fi
} > "$out"

(( warn == 0 ))
