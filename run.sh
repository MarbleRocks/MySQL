#!/bin/bash

#/etc/passwd:mysql:x:1001:1001:Default Application User:/home/mysql:/sbin/nologin
#/etc/group:mysql:x:1001:
# This version runs under WSL Ubuntu 24.04 on Windows 11
#

function check_build_dirs
{
	DIRS=$BACKUP $DATA $LOG
	for d in $DIRS
	do
		if [ ! -d $d ]; then
			sudo mkdir -p $d
		fi
done		
sudo chown -Rv 1001:1001 $BASEDIR/$CONTAINER
}


function init_db
{
	docker stop $CONTAINER; docker rm $CONTAINER
	check_build_dirs
	sudo rm -rfv $DATA/*
	sudo chown -Rv 1001:1001 $BASEDIR/$CONTAINER ${PWD}/Dirs
	sudo ls -al $DATA/*

	docker run \
		--name $CONTAINER \
		--user "1001:1001" \
		--detach \
		--restart on-failure \
		--env-file naboo.env \
		--network external \
		--ip $IP_EXT \
		-p '3306:3306' \
		-v $DATA:/var/lib/mysql \
		-v ${PWD}/Dirs/Config:/etc/mysql \
		-v ${PWD}/Dirs/bin:/tmp/bin \
		$IMAGE \
			--initialize-insecure 
}

function regular_run
{
	docker stop $CONTAINER; docker rm $CONTAINER
	docker run \
		--privileged \
		--name $CONTAINER \
		--user "1001:1001" \
		--detach \
		--restart always \
		--env-file falcon.env \
		--network external \
		--ip $IP_EXT \
		-p '3306:3306' \
		-v ${PWD}/Dirs/Config:/etc/mysql \
		-v $DATA:/var/lib/mysql \
		-v ${BACKUP}:/BACKUP \
		-v ${LOG}:/var/log/mysql \
		-v ${PWD}/Dirs/bin:/tmp/bin \
		-v /home/amitlocal/ProjectCreightonU/LOAD_CMDB.csv:/var/lib/mysql-files/LOAD_CMDB.csv \
		-v /home/amitlocal/ProjectCreightonU:/home/mysql/ProjectCreighton  \
		$IMAGE \
			--character-set-server=UTF8MB4 --collation-server=UTF8MB4_GENERAL_CI

	docker network connect --ip $IP_INT internal ${CONTAINER}
}

############################# MAIN #################################
export CONTAINER=NabooDB
export IMAGE=percona/percona-server:8.4
export BASEDIR="/mnt/c/Users/amipate/opt/docker/MySql"
export DATA="$BASEDIR/${CONTAINER}/DATA"
export BACKUP="$BASEDIR/${CONTAINER}/BACKUP"
export LOG="$BASEDIR/${CONTAINER}/LOG"
export IP_EXT="10.168.10.10"
export IP_INT="10.168.11.10"
if [ -f $DATA/mysql.ibd ]; then
	echo "Database exists"
	regular_run
else
	echo "No Database"
	init_db
fi




#-v ${PWD}/Dirs/Config/my.cnf:/etc/my.cnf \
#-v /opt/docker/MySql/${CONTAINER}/DATA:/var/lib/mysql \
