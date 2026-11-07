#!/usr/bin/env bash
# sysinfo.sh - quick system summary
set -euo pipefail

show_disk() { echo "Disk:     $(df -h --output=pcent,avail / | tail -1)"; }
show_mem()  { echo "Memory:   $(free -h | awk '/^Mem:/ {print $7}') available"; }

case "${1:-all}" in
    disk) show_disk ;;
    mem)  show_mem ;;
    all)
        echo "Hostname: $(hostname)"
        echo "IPs:      $(hostname -I)"
        echo "Uptime:   $(uptime -p)"
        show_mem
        show_disk ;;
    *)  echo "Usage: $0 [all|disk|mem]" >&2; exit 1 ;;
esac
