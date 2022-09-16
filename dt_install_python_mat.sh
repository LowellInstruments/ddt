#!/usr/bin/env bash


VENV=/home/pi/li/venv
VPIP=$VENV/bin/pip


printf '\n\n\n---- Install MAT ----\n'

printf '\nI > MAT library...\n'
source $VENV/bin/activate
$VPIP install --no-deps --force-reinstall git+https://github.com/LowellInstruments/lowell-mat.git@v4

printf 'I > MAT library OK\n'