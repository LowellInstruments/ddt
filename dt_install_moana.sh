#!/usr/bin/bash


clear


PATH_MOANA_FILE=_dt_files/bleak_moana.py
PATH_DDH_FOLDER_PYCHARM=$HOME/PycharmProjects/ddh/ddh/threads
PATH_DDH_FOLDER_REAL=/home/pi/li/ddh/ddh/threads
_E="error installing moana file"



cat /proc/cpuinfo | grep Raspberry
rv=$?



if [ $rv -eq 0 ]; then
    printf "raspberry platform detected, installing moana file..."
    cp $PATH_MOANA_FILE $PATH_DDH_FOLDER_REAL || echo "$_E"

else
    printf "NON-raspberry platform detected, installing moana file..."
    cp $PATH_MOANA_FILE $PATH_DDH_FOLDER_PYCHARM || echo "$_E"
fi


printf "\nend\n"

