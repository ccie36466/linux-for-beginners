#!/usr/bin/env bash
# snapshot-backup.sh - daily rsync snapshots with hard links and retention
# Usage: snapshot-backup.sh   (run as root, e.g. from a systemd timer)
set -euo pipefail

SOURCES=(/etc /home /var/www)    # what to back up
DEST=/data/snapshots             # where snapshots live
KEEP=14                          # how many daily snapshots to keep

today=$(date +%F)
target="$DEST/$today"
latest="$DEST/latest"

mkdir -p "$DEST"
echo "$(date '+%F %T') Backup to $target starting"

link_opt=()
[[ -d "$latest" ]] && link_opt=(--link-dest="$latest")

rsync -aAXH --delete --relative "${link_opt[@]}" \
    "${SOURCES[@]}" "$target/"
ln -sfn "$target" "$latest"

# Retention: delete the oldest snapshots beyond $KEEP
mapfile -t old < <(find "$DEST" -mindepth 1 -maxdepth 1 -type d \
    -name '20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]' | sort | head -n -"$KEEP")
for dir in "${old[@]}"; do
    echo "Removing old snapshot $dir"
    rm -rf -- "$dir"
done

echo "$(date '+%F %T') Backup finished: $(du -sh "$target" | cut -f1)"
