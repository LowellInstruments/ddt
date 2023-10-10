#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt
F_IN=/usr/local/bin


printf '\n\n\n---- dt_install_utils ----\n'


printf '\n\n>>> installing climenu\n'
sudo killall cm
sudo cp $F_DT/_dt_files/cm $F_IN
sudo cp $F_DT/_dt_files/cm_ddh.conf /etc/
grep 'alias cm' /home/pi/.bashrc
rv=$?
if [ $rv -ne 0 ]; then
    echo -e 'alias cm="/usr/local/bin/cm /etc/cm_ddh.conf"\n' >> /home/pi/.bashrc

fi
sudo chmod +x $F_IN/cm


printf '\n\n>>> dt_install_utils = OK\n'
