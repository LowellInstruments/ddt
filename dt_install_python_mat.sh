#!/usr/bin/env bash


# grab variables from file
. ./_dt_files/dt_variables.sh || (echo 'dt_vars fail'; exit 1)


printf '\n\n\n---- Install MAT ----\n'


printf '\n[ MAT ] activating venv\n\n'
source "$VENV"/bin/activate
rv=$?
if [ "$rv" -ne 0 ]; then
    printf '\n[ MAT ] cannot activate VENV, quitting.\n\n'
    exit 1
fi


# try to accelerate the process
if [ -d "$F_DT" ]; then
    printf "\n[ MAT ] trying to install from %s/_wheels\n\n" "$F_DT"
    "$VPIP" install "$F_DT"/_wheels/*.whl
fi


printf '\n[ MAT ] installing library\n\n'
#"$VPIP" install --upgrade --force-reinstall git+https://github.com/lowellinstruments/lowell-mat.git@v4
"$VPIP" install --upgrade git+https://github.com/lowellinstruments/lowell-mat.git@v4


printf '\n[ MAT ] installed OK\n\n'
