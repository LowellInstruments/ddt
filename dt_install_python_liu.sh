#!/usr/bin/env bash


VPIP=/home/pi/li/venv/bin/pip


printf '\n[ LIU ] --- running install_liu.sh ---\n\n'


printf '\n[ LIU ] activating venv\n\n'
source "$F_LI"/venv/bin/activate
rv=$?
if [ "$rv" -ne 0 ]; then
    printf '\n[ LIU ] cannot activate venv, quitting.\n\n'
    exit 1
fi


printf '\n[ LIU ] installing library\n\n'
"$VPIP" uninstall -y liu
"$VPIP" install --upgrade git+https://github.com/lowellinstruments/liu.git


printf '\n[ LIU ] installed OK!\n\n'
