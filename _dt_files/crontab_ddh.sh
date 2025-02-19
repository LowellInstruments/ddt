#!/usr/bin/env bash


# don't run when BRT tool is running
ps -aux | grep main_brt | grep -v grep
rv=$?
if [ $rv -eq 0 ]; then
    printf "detected BRT running, DDH leaving\n"
    exit 0
fi


# run DDS if NOT already running
pgrep -f run_dds.sh
rv=$?
if [ $rv -ne 0 ]; then
    /home/pi/li/ddh/run_dds.sh&
fi



# run DDH if NOT already running
pgrep -f run_ddh.sh
rv=$?
if [ $rv -ne 0 ]; then
    /home/pi/li/ddh/run_ddh.sh&
fi



# so it does not leave instantaneously
read -r
read -r
read -r
