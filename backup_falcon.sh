#!/bin/bash

function print_variables
{
	printf "In print_variables:\n"
	printf "\tCONTAINER:\t$CONTAINER\n"
	printf "\tBACKUPDIROS:\t$BACKUPDIROS\n"
	printf "\tGITDIR:\t\t$GITDIR\n"
	printf "\tDATADIR:\t\t$DATADIR\n"

}

function backup_DB
{
	docker exec -it $CONTAINER /tmp/bin/mysql_backup.sh
}

function backup_git
{
	pushd $BACKUPDIROS
	pwd
	ls
	cmd="sudo tar cf $BACKUPFILE $GITDIR $DATADIR"
	echo $cmd
	docker pause $CONTAINER
	$cmd
	docker unpause $CONTAINER
	ls -al $BACKUPDIROS
	popd
}

################################################################################
export CONTAINER=FalconDB
export TAG=$(date +%Y%m%d)
export GITDIR=$PWD
export DATADIR="/opt/docker/MySql/${CONTAINER}/DATA"
export BACKUPDIROS="/opt/docker/MySql/${CONTAINER}/BACKUP"
export BACKUPFILE="$BACKUPDIROS/gitbackup_$CONTAINER_$TAG.tar"

cd $GITDIR
print_variables
backup_git
backup_DB

