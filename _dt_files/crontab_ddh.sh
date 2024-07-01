#!/usr/bin/env bash


# don't run if BRT tool is running
ps -aux | grep brt | grep -v grep
rv=$?
if [ $rv -eq 0 ]; then
    printf "detected BRT running, DDH leaving\n"
    exit 0
fi



/home/pi/li/ddh/run_dds.sh&

# prevents mangled output at start
sleep 1

/home/pi/li/ddh/run_ddh.sh&

# so it does not leave instantaneously
read -r
read -r
read -r
