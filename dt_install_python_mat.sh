#!/usr/bin/env bash


# ==========================================================
# called by dt_update_all_ddh.sh once per day,
# which also checks for internet connectivity
# ==========================================================


F_LI=/home/pi/li
VPIP="$F_LI"/venv/bin/pip
FLAG_DDH_UPDATED=/tmp/ddh_got_update_file.flag


printf '\n[ MAT ] --- running install_mat.sh ---\n\n'


printf '\n[ MAT ] activating venv\n\n'
source "$F_LI"/venv/bin/activate
rv=$?
if [ $rv -ne 0 ]; then printf "[ MAT ] failed sourcing venv \n"; exit 1; fi


printf '\n[ MAT ] cloning library\n\n'
git clone https://github.com/lowellinstruments/mat.git
rv=$?
if [ $rv -ne 0 ]; then printf "[ MAT ] failed cloning \n"; exit 1; fi


printf '\n[ MAT ] emptying setup.py from requirements\n\n'
cp mat/tools/_setup_wo_reqs.py mat/setup.py
rv=$?
if [ $rv -ne 0 ]; then printf "[ MAT ] failed installing empty setup.py \n"; exit 1; fi


printf '\n[ MAT ] installing library\n\n'
"$VPIP" uninstall -y mat || true
"$VPIP" install ./mat
rv=$?
if [ $rv -ne 0 ]; then printf "[ MAT ] failed installing library core \n"; exit 1; fi
rm -rf ./mat || true
touch "$FLAG_DDH_UPDATED"
rv=$?
if [ $rv -ne 0 ]; then printf "[ MAT ] failed installing DDH_UPDATED file flag \n"; exit 1; fi
printf '\n[ MAT ] installed OK!\n\n'
exit 0
