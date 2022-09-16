#!/usr/bin/env bash
DDT=/home/pi/li/ddh_tools


# abort upon any error
clear && echo && set -e
trap 'echo ‘$BASH_COMMAND’ TRAPPED! rv $?' EXIT



printf '\n\n\n---- Install AVAHI ----\n'


if [ "$#" -ne 1 ]; then
    echo "E > needs one parameter SN, length 7"
    exit 1
fi
LEN=$(expr length "$1")
if [ "$LEN" -ne 7 ]; then
    echo "E > parameter length must be 7"
    exit 1
fi

SED_STR="s/host-name=.*/host-name=ddh_$1/"
echo "I > setting AVAHI name as:"
echo "    $SED_STR"
sed -i "$SED_STR" $DDT/_dt_files/avahi-daemon.conf
sudo cp $DDT/_dt_files/avahi-daemon.conf /etc/avahi/
sudo systemctl restart avahi-daemon.service
echo "I > done DDH setup AVAHI $ ping ddh_$1.local"
