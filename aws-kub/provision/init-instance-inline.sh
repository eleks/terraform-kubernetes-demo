#!/bin/bash

# script used to run ./init-instance.sh that's actually init-<instance-name>
# for example: init-master.sh in case if that's master
# this script executed as inline to make logging only on error

set -e
chmod +x /home/centos/provision/init-instance.sh
LOG_FILE=/home/centos/provision/init-instance.log
/home/centos/provision/init-instance.sh &> $LOG_FILE || (>&2 tail -20 $LOG_FILE && exit 1 )
echo SUCCESS
