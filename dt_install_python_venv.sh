#!/usr/bin/env bash
LI=/home/pi/li
FOL_DDT=$LI/ddt
VENV=$LI/venv
VPIP=$VENV/bin/pip


# abort upon any error
clear && echo && set -e
trap 'echo ‘$BASH_COMMAND’ TRAPPED! rv $?' EXIT
if [ $PWD != $FOL_DDT ]; then echo 'wrong starting folder'; exit 1; fi


# on RPi, venv needs to inherit PyQt5 installed via apt
printf 'I > virtualenv \n'
rm -rf $VENV || true
python3 -m venv $VENV --system-site-packages
source $VENV/bin/activate
$VPIP install --upgrade pip
$VPIP install wheel
