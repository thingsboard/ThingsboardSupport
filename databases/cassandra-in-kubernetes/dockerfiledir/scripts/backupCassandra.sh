#!/bin/bash

if [ ! "$WORKDIR" ]; then
	WORKDIR="/data/backup/"
fi

if [ ! "$DB" ]; then
	DB="/var/lib/cassandra/data/thingsboard"
fi

LOG="${WORKDIR}BackupCassandra.log"
WEBHOOK_FILE="WebhookMessageCassandra.log"

mkdir -p $WORKDIR
chmod -R o+rw $WORKDIR
exec > >(tee -ia $LOG $WEBHOOK_FILE)
exec 2> >(tee -ia $LOG $WEBHOOK_FILE >&2)
truncate -s 0 $WEBHOOK_FILE
find $WORKDIR -mtime "$BACKUP_TTL_DAYS" -exec rm -f {} \; # delete backup older than * days

echo -e "\n---- Start Cassandra backup process at $(date +'%d-%b-%y_%H:%M') ----"

AVAIL=$(df -m "$DATASTORE" | awk '{print $4}' | tail -1)
FILESIZE=$(du -sm $DB | awk '{print int($1)}')

echo "Free space: ${AVAIL} Mb"
echo "Cassandra DB size: ${FILESIZE} Mb"

if [ "$FILESIZE" -ge "$AVAIL" ]; then
	echo " Not enought free space"
else
	echo " Enought free space, starting..."

	cqlsh -e "DESCRIBE KEYSPACE thingsboard;" > "${WORKDIR}"thingsboard-describe.txt
	TARFILE=${WORKDIR}$(date +'%d-%b-%y_%H-%M')-cassandra.tar
	cd "${WORKDIR}" || exit
	tar -cf "${TARFILE}" -P "${DB}" thingsboard-describe.txt
	rm -rf "${WORKDIR}"thingsboard-describe.txt

	TARFILE_SIZE=$(du -m "$TARFILE" | awk '{print $1}')
	echo "Completed. Backup file size: ${TARFILE_SIZE} Mb"
	if [ 1 -ge "$TARFILE_SIZE" ]; then
		echo "WARN. Backup file is less then 1 Mb"
	fi
fi
echo -e "------- Backup process finished at $(date +'%d-%b-%y_%H:%M') -------\n"


if [ "$WEBHOOK" ]; then
	WEBHOOK_DATA="{\"text\":\"$(cat $WEBHOOK_FILE)\"}"
	curl -X POST -H 'Content-type: application/json' --data "$WEBHOOK_DATA" "$WEBHOOK"
else
    echo -e "\n WEBHOOK URL is not specified"
fi