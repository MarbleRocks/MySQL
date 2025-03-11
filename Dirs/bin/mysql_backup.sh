#!/bin/bash


function print_variables
{
	printf "In print_variables:\n"
	printf "\tCONTAINER:\t$CONTAINER\n"
	printf "\tIMAGE:\t\t$IMAGE\n"
	printf "\tDUMPDIR:\t$DUMPDIR\n"
	printf "\tTAG:\t\t$TAG\n"
	printf "\tDUMPFILE:\t$DUMPFILE\n"

}

function backup_DB
{
#	cmd="mysqldump --allow-keywords --column-statistics --comments --disable-keys --lock-for-backup --single-transaction --order-by-primary --all-databases --user=root > $DUMPFILE"
	cmd="mysqldump -u root --all-databases --single-transaction --order-by-primary"
	echo $cmd
	$cmd > $DUMPFILE
}

export TAG=$(date +%Y%m%d)
export CONTAINER=FalconDB
export IMAGE=percona/percona-server:8.4
export DUMPDIR="/BACKUP"
export DUMPFILE="$DUMPDIR/cdw_dump_$CONTAINER_$TAG.dmp"

print_variables
pushd $DUMPDIR
backup_DB
pwd
ls -al


popd
