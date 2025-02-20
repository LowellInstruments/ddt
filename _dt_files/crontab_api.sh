#!/usr/bin/env bash


# run API if NOT already running
pgrep -f run_api.sh
rv=$?
if [ $rv -ne 0 ]; then
    /home/pi/li/ddh/run_api.sh&
fi
