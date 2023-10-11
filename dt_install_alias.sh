#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt
F_IN=/usr/local/bin


printf '\n\n\n---- dt_install_alias ----\n'


printf '\n\n>>> installing aliases DDC and DDI\n'
sudo killall cm
sudo cp $F_DT/_dt_files/cm $F_IN
sudo cp $F_DT/_dt_files/cmc.conf /etc/
sudo cp $F_DT/_dt_files/cmi.conf /etc/
grep 'alias ddc' /home/pi/.bashrc
rv=$?
if [ $rv -ne 0 ]; then
    echo -e 'alias ddc="/usr/local/bin/cm /etc/cmc.conf"\n' >> /home/pi/.bashrc
fi
grep 'alias ddi' /home/pi/.bashrc
rv=$?
if [ $rv -ne 0 ]; then
    echo -e 'alias ddi="/usr/local/bin/cm /etc/cmi.conf"\n' >> /home/pi/.bashrc
fi
sudo chmod +x $F_IN/cm


printf '\n\n>>> dt_install_alias OK\n'
