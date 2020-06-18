#!/usr/bin/env bash

# This script assumes assumes that Docker 1.8 or higher is used.
cmdname=$(basename $0)

ORIENTDB_CONTAINER=$1
TDMWEB_CONTAINER=$2
FILE_NAME=$3

usage()
{
    cat << USAGE >&2
Usage:
    $cmdname orientdb tdmweb [file]
    orientdb                    OrientDB container name or hash
    tdmweb                      TDMWeb container name or hash
    file                        Relative or absolute path to a file to store the tar gz output, default is tdm-volumes-backup-4.7.tar.gz
                                in working directory
USAGE
    exit 1
}

# $1 container
check_container() {
    echo "INFO: validating '$1' container for backup"
    local RUNNING=$(docker container inspect -f '{{ .State.Running }}' $1 2> /dev/null)
    if [[ "$RUNNING" == "" ]]; then
        echo "ERROR: No such container container '$1'"
        exit 1
    fi
    if [[ "$RUNNING" == "true" ]]; then
        echo "ERROR: You have to stop '$1' container before running backup"
        exit 1
    fi
    echo "INFO: container '$1' is OK for backup"
}

# $1 container
# $2 mount
# $3 target tgz file name
backup_volume() {
    echo "INFO: backing up '$1$2' into '$3'"
    docker run --rm --volumes-from $1 busybox tar -cz $2 > $3
    echo "INFO: volume baked up into $3"
}

if [[ $# -lt 2 ]]; then
   usage
fi

check_container $ORIENTDB_CONTAINER
check_container $TDMWEB_CONTAINER

temp=$(mktemp -d)
echo "INFO: creating temporary directory '$temp'"

backup_volume $ORIENTDB_CONTAINER /orientdb/backup $temp/orientdb-backup-4.7-backup.tar.gz
backup_volume $ORIENTDB_CONTAINER /orientdb/config $temp/orientdb-config-4.7-backup.tar.gz
backup_volume $ORIENTDB_CONTAINER /orientdb/databases $temp/orientdb-databases-4.7-backup.tar.gz

backup_volume $TDMWEB_CONTAINER /mnt/logs $temp/tdmweb-logs-4.7-backup.tar.gz
backup_volume $TDMWEB_CONTAINER /mnt/storage $temp/tdmweb-storage-4.7-backup.tar.gz

if [[ "$FILE_NAME" == "" ]]; then
    FILE=$(pwd)/tdm-volumes-backup-4.7.tar.gz
else
    if [[ "$FILE_NAME" = /* ]]; then
        FILE=$FILE_NAME
    else
        FILE=$(pwd)/$FILE_NAME
    fi
fi

pushd $temp
tar -czf $FILE *.tar.gz
popd

echo "INFO: '$FILE' archive created"

echo "INFO: deleting temporary directory '$temp'"
rm -rf $temp
