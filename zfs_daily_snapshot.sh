#!/bin/sh

# Retention and pool name parameters
RETENTION_DAYS=7
POOL="zroot"

DATE=$(date +%F)
SNAPNAME="daily-${DATE}"

# Create snapshots for all datasets in the pool
DATASETS=$(zfs list -H -o name -r "$POOL")
for ds in $DATASETS; do
  SNAP="${ds}@${SNAPNAME}"
  if ! zfs list -t snapshot -o name | grep -q "^${SNAP}$"; then
    echo "Creating snapshot: $SNAP"
    zfs snapshot "$SNAP"
  else
    echo "Snapshot ${SNAP} already exists, skipping."
  fi

  # Prune old snapshots for this dataset
  SNAPSHOTS=$(zfs list -t snapshot -o name -s creation | grep "^${ds}@daily-")
  COUNT=$(echo "$SNAPSHOTS" | wc -l)
  if [ "$COUNT" -gt "$RETENTION_DAYS" ]; then
    NUM_TO_DELETE=$((COUNT - RETENTION_DAYS))
    echo "$SNAPSHOTS" | head -n "$NUM_TO_DELETE" | while read OLD_SNAP; do
      echo "Deleting old snapshot: $OLD_SNAP"
      zfs destroy -r "$OLD_SNAP"
    done
  fi

done