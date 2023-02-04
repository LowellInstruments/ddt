#!/usr/bin/env bash


# ==========================================================
# called by dt_install_python_all_mat_ddh.sh once per day,
# which also checks for internet connectivity
# ==========================================================


F_LI=/home/pi/li
VPIP="$F_LI"/venv/bin/pip
FLAG_DDH_UPDATED=/tmp/ddh_got_update_file.flag


# abort upon any error
set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


printf '\n[ MAT ] --- running install_mat.sh ---\n\n'


printf '\n[ MAT ] activating venv\n\n'
source "$F_LI"/venv/bin/activate


printf '\n[ MAT ] cloning library\n\n'
"$VPIP" clone https://github.com/lowellinstruments/lowell-mat.git -b v4
cp lowell-mat/tools/_setup_wo_reqs.py lowell-mat/setup.py


printf '\n[ MAT ] installing library\n\n'
"$VPIP" uninstall -y lowell-mat || true
"$VPIP" install ./lowell-mat
rm -rf ./lowell-mat || true
touch "$FLAG_DDH_UPDATED"
printf '\n[ MAT ] installed OK!\n\n'
