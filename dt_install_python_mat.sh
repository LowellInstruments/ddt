#!/usr/bin/env bash


VENV=/home/pi/li/venv
VPIP="$VENV"/bin/pip
TM=/tmp/lowell-mat



printf '\n\n\n---- Install MAT ----\n'

printf '\nI > MAT library...\n'
source $VENV/bin/activate

pip install https://github.com/lowellinstruments/lowell-mat.git@v4

printf 'I > MAT library OK\n'
