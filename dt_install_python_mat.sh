#!/usr/bin/env bash


# grab variables from file
. ./_dt_files/dt_variables.sh || (echo 'dt_vars fail'; exit 1)


printf '\n\n\n---- Install MAT ----\n'


printf '\n[ MAT ] activating venv\n'
source "$VENV"/bin/activate
rv=$?
if [ "$rv" -ne 0 ]; then
    echo '[ MAT ] cannot activate VENV, quitting'
    exit 1
fi


printf '\n[ MAT ] installing library...\n'
#pip install --upgrade --force-reinstall git+https://github.com/lowellinstruments/lowell-mat.git@v4
pip install --upgrade git+https://github.com/lowellinstruments/lowell-mat.git@v4


printf '[ MAT ] installation OK\n'
