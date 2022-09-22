#!/usr/bin/env bash


# dt_update_x is called at rc.local


FH=/home/pi/li/ddh


printf "crontab -> ddh_run.sh\n"


cd $FH || false
$FH/ddh_run.sh&
rv=$?
if [ $rv -ne 0 ]; then
    printf "crontab could not run DDH!"
    exit 1
fi

$FH/dds/dds_run.sh&
rv=$?
if [ $rv -ne 0 ]; then
    printf "crontab could not run DDS!"
    exit 1
fi