#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT
if [ "$PWD" != "$F_DT" ]; then echo 'wrong starting folder'; exit 1; fi


printf '\n\n\n---- dt_install_linux_bluez ----\n'


printf '\n\n>>> Installing btuart patch\n'
grep Raspberry /proc/cpuinfo
rv=$?
if [ $rv -eq 0 ]; then
    sudo cp _dt_files/btuart /usr/bin/
    sudo chown root /usr/bin/btuart
    sudo chgrp root /usr/bin/btuart
fi


printf '\n\n>>> uncompressing bluez from _dt_files folder\n'
cd _dt_files
wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.66.tar.xz
rv=$?
if [ $rv -ne 0 ]; then
    echo 'error wget bluez'
    exit 1
fi
rm bluez-5.66.tar.xz || true
unxz bluez-5.66.tar.xz
tar xvf bluez-5.66.tar


printf '\n\n>>> configuring and building bluez\n'
cd bluez-5.66
./configure
make
sudo make install


printf '\n\n>>> dt_install_linux_bluez = OK\n'
