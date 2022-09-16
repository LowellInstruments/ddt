#!/usr/bin/env bash


VENV=/home/pi/li/venv
VPIP=$VENV/bin/pip
TM=/tmp/lowell-mat



printf '\n\n\n---- Install MAT ----\n'

printf '\nI > MAT library...\n'
source $VENV/bin/activate

git clone -b v4 https://github.com/lowellinstruments/lowell-mat.git "$TM"
$VPIP install -r $TM/requirements.txt

printf 'I > MAT library OK\n'
