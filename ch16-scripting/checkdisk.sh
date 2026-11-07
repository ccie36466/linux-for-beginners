#!/usr/bin/env bash
# checkdisk.sh - warn when the root filesystem is too full
set -euo pipefail

limit=${1:-80}
usage=$(df --output=pcent / | tail -1 | tr -dc '0-9')

if (( usage >= limit )); then
    echo "WARNING: / is ${usage}% full (limit ${limit}%)"
    exit 1
else
    echo "OK: / is ${usage}% full"
fi
