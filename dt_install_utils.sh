#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT
if [ "$PWD" != "$F_DT" ]; then echo 'wrong starting folder'; exit 1; fi


printf '\n\n\n---- dt_install_utils ----\n'


printf '\n\n>>> installing climenu\n'
sudo cp $F_DT/_dt_files/cm /usr/local/bin
sudo cp $F_DT/_dt_files/cm_ddh.conf /etc/
grep 'alias cm' /home/pi/.bashrc
rv=$?
if [ $rv -ne 0 ]; then
    echo 'alias cm="/usr/local/bin/cm"' >> /home/pi/.bashrc
fi


printf '\n\n>>> dt_install_utils = OK\n'
