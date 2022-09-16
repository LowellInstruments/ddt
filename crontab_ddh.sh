#!/usr/bin/env bash


# update is called at rc.local


# call DDS
FS=/home/pi/li/dds
printf "crontab -> dds_run.sh\n"
cd $FS || false
$FS/dds_run.sh &
rv=$?
if [ $rv -ne 0 ]; then
    printf "crontab could not run DDS!"
    exit 1
fi


# call DDH
FH=/home/pi/li/ddh
printf "crontab -> ddh_run.sh\n"
cd $FH || false
$FH/ddh_run.sh
rv=$?
if [ $rv -ne 0 ]; then
    printf "crontab could not run DDH!"
    exit 1
fi