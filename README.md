# OPNsense-ZFS-Snapshot
Scripts for managing ZFS snapshots and restoring on an OPNsense system.

## Overview

This repository contains two shell scripts for managing ZFS snapshots on an OPNsense system:

- zfs_daily_snapshot.sh: Automatically creates ZFS snapshots for all datasets in the specified pool (`zroot` by default). It also prunes older snapshots, keeping only a set number of recent daily snapshots (default: 7 days). This is designed to be run via cron daily, refer to the section below.
- zfs_RESTORE.sh: Allows you to restore all datasets in the pool to a specific daily snapshot by date. It lists available snapshots, prompts for confirmation, and rolls back datasets to the chosen snapshot.

## Cron
The `zfs_daily_snapshot.sh` is designed to be run daily via cron. You can either do this through the preferred method of adding a service to [configd, more info here](https://docs.opnsense.org/development/backend/configd.html). Or you can add it to crontab directly.

## Restore
The `zfs_RESTORE.sh` script allows you to roll back all datasets in the pool to a specific daily snapshot by date.

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
- Prompt for confirmation before proceeding, warning that all changes after the selected snapshot will be destroyed.
- Roll back all datasets under the pool to the specified snapshot, processing deepest datasets first to avoid dependency issues.
- Skip any datasets that do not have the requested snapshot.