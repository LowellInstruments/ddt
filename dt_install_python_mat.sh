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
git clone https://github.com/lowellinstruments/mat.git


printf '\n[ MAT ] emptying setup.py from requirements\n\n'
cp mat/tools/_setup_wo_reqs.py mat/setup.py


printf '\n[ MAT ] installing library\n\n'
"$VPIP" uninstall -y mat || true
"$VPIP" install ./mat
rm -rf ./mat || true
touch "$FLAG_DDH_UPDATED"
printf '\n[ MAT ] installed OK!\n\n'
