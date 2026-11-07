#!/usr/bin/env bash
# netmon.sh - check hosts and web services, log changes of state
# Usage: netmon.sh /etc/netmon/targets.txt
# Target lines:  ping NAME HOST | tcp NAME HOST PORT | http NAME URL
set -uo pipefail

targets="${1:-/etc/netmon/targets.txt}"
state_dir=/var/lib/netmon
log=/var/log/netmon.log
# Optional: set NETMON_WEBHOOK to a chat webhook URL for alerts
webhook="${NETMON_WEBHOOK:-}"
mkdir -p "$state_dir"

log_msg() { echo "$(date '+%F %T') $*" >> "$log"; }

alert() {
    log_msg "ALERT $*"
    if [[ -n "$webhook" ]]; then
        curl -s -m 10 -H "Content-Type: application/json" \
            -d "{\"text\": \"$(hostname): $*\"}" "$webhook" \
            > /dev/null || true
    fi
}

check() {
    local type="$1" name="$2" target="$3" port="${4:-}" detail
    case "$type" in
        ping)
            detail=$(ping -c 3 -W 2 -q "$target" 2>/dev/null \
                | awk -F/ '/^rtt/ {print $5 " ms"}')
            [[ -n "$detail" ]] ;;
        tcp)
            detail="port $port"
            nc -z -w 3 "$target" "$port" > /dev/null 2>&1 ;;
        http)
            detail=$(curl -s -o /dev/null -m 10 \
                -w "%{http_code} %{time_total}s" "$target")
            [[ "$detail" == 2* || "$detail" == 3* ]] ;;
        *)
            log_msg "Unknown check type '$type' for $name"
            return 2 ;;
    esac
    local rc=$?
    local now; now=$([[ $rc -eq 0 ]] && echo UP || echo DOWN)
    local file="$state_dir/$name.state"
    local before; before=$(cat "$file" 2>/dev/null || echo UNKNOWN)
    if [[ "$now" != "$before" ]]; then
        echo "$now" > "$file"
        if [[ "$now" == DOWN ]]; then
            alert "$name is DOWN ($type $target)"
        elif [[ "$before" == UNKNOWN ]]; then
            log_msg "$name is UP (first check)"
        else
            alert "$name is UP again ($type $target, ${detail:-ok})"
        fi
    fi
    printf "%-12s %-5s %-4s %s\n" "$name" "$type" "$now" "${detail:-}"
}

while read -r type name target port; do
    [[ -z "${type:-}" || "$type" == \#* ]] && continue
    check "$type" "$name" "$target" "${port:-}"
done < "$targets"
