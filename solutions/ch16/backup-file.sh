#!/usr/bin/env bash
# backup-file.sh - copy a file to FILE.YYYY-MM-DD
set -euo pipefail

file="${1:-}"
if [[ -z "$file" ]]; then
    echo "Usage: $0 FILE" >&2
    exit 1
fi
if [[ ! -f "$file" ]]; then
    echo "Error: $file does not exist" >&2
    exit 1
fi

dest="${file}.$(date +%F)"
cp -p -- "$file" "$dest"
echo "Saved $dest"
