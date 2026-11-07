#!/usr/bin/env bash
# netcheck.sh - check ping and SSH for every server in a list
# Usage: netcheck.sh servers.txt
set -euo pipefail

list="${1:-servers.txt}"
[[ -r "$list" ]] || { echo "Cannot read $list" >&2; exit 1; }

failures=0

check() {
    local name="$1" ip="$2" ping_ok="no" ssh_ok="no"
    ping -c 1 -W 1 "$ip" > /dev/null 2>&1 && ping_ok="yes"
    nc -z -w 2 "$ip" 22 > /dev/null 2>&1 && ssh_ok="yes"
    printf "%-10s %-15s ping=%-3s ssh=%s\n" "$name" "$ip" "$ping_ok" "$ssh_ok"
    [[ "$ping_ok" == "yes" && "$ssh_ok" == "yes" ]]
}

while read -r name ip; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    check "$name" "$ip" || failures=$((failures + 1))
done < "$list"

echo "Problems found: $failures"
(( failures == 0 ))
