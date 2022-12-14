#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt
VENV="$F_LI"/venv
VPIP="$VENV"/bin/pip


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT
if [ "$PWD" != "$F_DT" ]; then echo 'wrong starting folder'; exit 1; fi


# on RPi, venv needs to inherit PyQt5 installed via apt
printf '\n[ VENV ] installing ... \n\n'
rm -rf "$VENV" || true
rm -rf "$HOME"/.cache/pip || true
python3 -m venv "$VENV" --system-site-packages
source "$VENV"/bin/activate
"$VPIP" install --upgrade pip
"$VPIP" install wheel

printf '\n[ VENV ] installed! \n\n'
