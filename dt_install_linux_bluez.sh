#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT
if [ "$PWD" != "$F_DT" ]; then echo 'wrong starting folder'; exit 1; fi


printf '\n\n\n---- dt_install_linux_bluez ----\n'


printf '\n\n>>> uncompressing bluez from _dt_files folder\n'
cd _dt_files
unxz bluez-5.66.tar.xz
tar xvf bluez-5.66.tar


printf '\n\n>>> configuring and building bluez\n'
cd bluez-5.66
./configure
make
sudo make install


printf '\n\n>>> dt_install_linux_bluez = OK\n'
