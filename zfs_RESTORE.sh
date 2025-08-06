#!/bin/sh

POOL="zroot"

# Show available main pool snapshots at start
echo "Available snapshots for the main pool dataset '$POOL':"
zfs list -t snapshot -r "$POOL" | grep "^$POOL@daily-"
echo ""

# Check for snapshot date argument
if [ -z "$1" ]; then
  echo "Usage: $0 YYYY-MM-DD"
  echo ""
  echo "Example: $0 2025-08-05"
  exit 1
fi

SNAPDATE="$1"
SNAPNAME="daily-${SNAPDATE}"

# Confirm with user before proceeding
echo "WARNING: Rolling back to snapshot '$SNAPNAME' will DESTROY all changes made after this snapshot!"
echo -n "Are you sure you want to continue? (yes/no): "
read CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Rollback aborted by user."
  exit 0
fi

echo "Rolling back all datasets under pool '$POOL' to snapshot '$SNAPNAME'..."

# List all datasets in reverse order (deepest first) using sort -r (since tac not available)
DATASETS=$(zfs list -H -o name -r "$POOL" | sort -r)

echo "$DATASETS" | while read -r ds; do
  SNAP="${ds}@${SNAPNAME}"
  if zfs list -t snapshot -o name | grep -q "^${SNAP}$"; then
    echo "Rolling back $ds to $SNAP"
    zfs rollback -r "$SNAP"
  else
    echo "Snapshot $SNAP not found for dataset $ds, skipping."
  fi
done

echo ""
echo "Rollback completed!"
