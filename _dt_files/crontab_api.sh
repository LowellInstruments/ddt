#!/usr/bin/env bash


# quit if DDU is running
pgrep -f pop_ddh.sh
rv=$?
if [ $rv -ne 0 ]; then
    exit 0
fi



# run API if NOT already running
pgrep -f run_api.sh
rv=$?
if [ $rv -ne 0 ]; then
    /home/pi/li/ddh/run_api.sh&
fi
