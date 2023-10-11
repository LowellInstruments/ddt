#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt
F_IN=/usr/local/bin
F_RC=/home/pi/.bashrc


printf '\n\n\n---- dt_install_alias ----\n'


printf '\n\n>>> building climenu as cm\n'
gcc $F_DT/_dt_files/cm -o $F_DT/_dt_files/climenu.c


printf '\n\n>>> installing aliases DDC and DDI\n'
sudo killall cm
sudo cp $F_DT/_dt_files/cm $F_IN
sudo cp $F_DT/_dt_files/cmc.conf /etc/
sudo cp $F_DT/_dt_files/cmi.conf /etc/
grep 'alias ddc' $F_RC
rv=$?
if [ $rv -ne 0 ]; then
    echo -e 'alias ddc="/usr/local/bin/cm /etc/cmc.conf"\n' >> $F_RC
fi
grep 'alias ddi' $F_RC
rv=$?
if [ $rv -ne 0 ]; then
    echo -e 'alias ddi="/usr/local/bin/cm /etc/cmi.conf"\n' >> $F_RC
fi
sudo chmod +x $F_IN/cm

source $F_RC
printf '\n\n>>> dt_install_alias OK\n'
