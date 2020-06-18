#!/usr/bin/env bash

# The script assume following named volume to be created before running:

#  orientdb_backup
#  orientdb_config
#  orientdb_databases
#  tdmweb_logs
#  tdmweb_storage

cmdname=$(basename $0)

ARCHIVE_FILE=$1

usage()
{
    cat << USAGE >&2
Usage:
    $cmdname archive
    archive                     Tar gz file created by 'backup-volumes-4.7.sh' utility
USAGE
    exit 1
}

# $1 volume name
check_volume() {
    echo "Validation '$1' volume to import data"
    local VOLUME=$(docker volume ls -f name=$1 --format "{{.Name}}")
    if [[ "$VOLUME" == "" ]]; then
        echo "ERROR: Volume '$1' doesn't exist. Expecting orientdb_backup, orientdb_config, orientdb_databases, tdmweb_logs, tdmweb_storage to exist and be empty"
        exit 1
    fi

    local FILES=$(docker run --rm --mount source=$1,target=/volume busybox ls -A /volume)

    if [[ "$FILES" != "" ]]; then
        echo "ERROR: Volume $1 is not empty, can't import backup"
        exit 1
    fi
    echo "'$1' is OK for import"
}

# $1 volume name
# $2 archive file
# $3 mount path
restore_volume() {
    echo "INFO: restoring '$3'"
    cat $2 | docker run --rm -i --mount source=$1,target=$3 busybox tar zxf -
    echo "INFO: '$3 restored"
}

if [[ $# -lt 1 ]]; then
   usage
fi

check_volume orientdb_backup
check_volume orientdb_config
check_volume orientdb_databases
check_volume tdmweb_logs
check_volume tdmweb_storage


temp=$(mktemp -d)
echo "INFO: creating temporary directory '$temp'"

tar -xzf $ARCHIVE_FILE -C $temp

pushd $temp
restore_volume orientdb_backup orientdb-backup-4.7-backup.tar.gz /orientdb/backup
restore_volume orientdb_config orientdb-config-4.7-backup.tar.gz /orientdb/config
restore_volume orientdb_databases orientdb-databases-4.7-backup.tar.gz /orientdb/databases

restore_volume tdmweb_logs tdmweb-logs-4.7-backup.tar.gz /mnt/logs
restore_volume tdmweb_storage tdmweb-storage-4.7-backup.tar.gz /mnt/storage
popd

echo "INFO: deleting temporary directory '$temp'"
rm -rf $temp
