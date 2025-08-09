# OPNsense-ZFS-Snapshot
Scripts for managing ZFS snapshots and restoring on an OPNsense system.

## Overview

This repository contains two shell scripts for managing ZFS snapshots on an OPNsense system:

- **zfs_daily_snapshot.sh**: Automatically creates ZFS snapshots for all datasets in the specified pool (`zroot` by default). It also prunes older snapshots, keeping only a set number of recent daily snapshots (default: 7 days). This is designed to be run via cron daily, refer to the [section below.](#Using-cron-and-configd-actions)
- **zfs_RESTORE.sh**: Allows you to restore all datasets in the pool to a specific daily snapshot by date. It lists available snapshots and rolls back datasets to the chosen snapshot.

## Restore
The `zfs_RESTORE.sh` script allows you to roll back all datasets in the pool to a specific daily snapshot by date. This should be run directly from the device booted into single user mode to avoid live changes. If you cannot boot into single user mode, boot from an OPNsense installer USB drive or other ZFS capable OS and restore manually from there.

### Usage
Run the script with the desired snapshot date as an argument:

```sh
./zfs_RESTORE.sh YYYY-MM-DD
```

For example, to restore to the snapshot from August 5, 2025:

```sh
./zfs_RESTORE.sh 2025-08-05
```

The script will:
- List available daily snapshots for the main pool dataset (`zroot` by default).
- Roll back all datasets under the pool to the specified snapshot, processing deepest datasets first to avoid dependency issues.
- Skip any datasets that do not have the requested snapshot.

## Using cron and configd actions
Using crontab natively has resulted in problems and missing jobs due to what I believe are overwrites from updates and the like. To properly perform cron jobs its better to use configd and the cron job UI. To integrate with OPNsense's configd system, copy the provided `actions_zfs_snapshot.conf` file to:

```
/usr/local/opnsense/service/conf/actions.d/
```

Then restart with `service configd restart`. This will register the snapshot script as a configd action. For more details, see the [OPNsense configd documentation](https://docs.opnsense.org/development/backend/configd.html).

### Adding a cron job in the UI
To schedule daily snapshots using the OPNsense web UI:
1. Go to **System > Settings > Cron**.
2. Click the **+** button to add a new job.
3. Set the command to run `/root/zfs_daily_snapshot.sh` (or the appropriate path).
4. Set the schedule to your desired time (e.g., daily at 2:00 AM).
5. Save and apply the changes.