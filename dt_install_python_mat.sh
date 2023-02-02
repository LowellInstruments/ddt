#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt
VPIP="$F_LI"/venv/bin/pip
FLAG_DDH_UPDATED=/tmp/ddh_got_update_file.flag


# ==========================================================
# called by crontab_ddh.sh once per day or manually
# internet connectivity is checked at dt_install_python_all
# ==========================================================


printf '\n[ MAT ] --- running install_mat.sh ---\n\n'


printf '\n[ MAT ] activating venv\n\n'
source "$F_LI"/venv/bin/activate
rv=$?
if [ "$rv" -ne 0 ]; then
    printf '\n[ MAT ] cannot activate venv, quitting.\n\n'
    exit 1
fi


# wheels: try to accelerate the process
# if [ -d "$F_DT" ]; then
#     printf "\n[ MAT ] trying to install from %s/_wheels\n\n" "$F_DT"
#     "$VPIP" install "$F_DT"/_wheels/*.whl
# fi


printf '\n[ MAT ] installing library\n\n'
# todo > test this
#"$VPIP" install --upgrade --force-reinstall git+https://github.com/lowellinstruments/lowell-mat.git@v4
"$VPIP" uninstall lowell-mat
"$VPIP" install --upgrade git+https://github.com/lowellinstruments/lowell-mat.git@v4


touch "$FLAG_DDH_UPDATED"
printf '\n[ MAT ] installed OK!\n\n'
