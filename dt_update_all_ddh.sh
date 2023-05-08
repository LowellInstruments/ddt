#!/usr/bin/env bash


F_LI=/home/pi/li
F_DA="$F_LI"/ddh
F_DT="$F_LI"/ddt
VENV="$F_LI"/venv


printf '\n[ DDH ] --- running install_all.sh ---\n\n'



# see we have internet access
ping -q -c 1 -W 2 www.google.com
rv=$?
if [ $rv -ne 0 ]; then
    printf '[ DDH ] install_all --> NO internet, NO updating'
    exit 1
fi
echo



# comment on RPi, uncomment when testing on laptop
# F_DA=/home/kaz/PycharmProjects/ddh/



# get REMOTE commit IDs for DDH folder
_RCID=$(git ls-remote https://github.com/lowellinstruments/ddh.git master | awk '{ print $1 }')
rv=$?
if [ "$rv" -ne 0 ]; then printf '[ DDH ] error: getting git remote commit ID \n'; exit 1; fi
if [ ${#_RCID} -ne 40 ]; then printf '[ DDH ] error: bad git remote commit ID \n'; exit 1; fi


# check DDH app folder exist
if [ -d "$F_DA" ]; then

    # get LOCAL commit IDs for DDH folder
    _LCID=$(cd "$F_DA" && git rev-parse master)
    if [ "$rv" -ne 0 ]; then printf '[ DDH ] error: getting git local commit ID \n'; exit 1; fi
    if [ ${#_LCID} -ne 40 ]; then printf '[ DDH ] error: bad git local commit ID \n'; exit 1; fi
    printf '[ DDH ] git remote commit ID %s\n' "$_RCID"
    printf '[ DDH ] git local  commit ID %s\n' "$_LCID"


    if [ "$1" == "force" ]; then
        printf '[ DDH ] forced update detected \n'
    else
        if [ "$_RCID" == "$_LCID" ]; then
          printf '[ DDH ] is up-to-date \n';
          exit 0;
        fi
    fi
else
    printf '[ DDH ] %s folder did not exist\n\n' "$F_DA"
fi


# =================================================
# update both parts of DDH
# uncomment on RPi, comment when testing on laptop
# =================================================
printf '[ DDH ] needs an update\n'
"$F_DT"/dt_install_python_mat.sh
rv=$?
if [ $rv -ne 0 ]; then
    printf '[ DDH ] error installing all: MAT library \n'
    exit 2
fi
"$F_DT"/dt_install_python_ddh.sh
rv=$?
if [ $rv -ne 0 ]; then
    printf '[ DDH ] error installing all: DDH application \n'
    exit 3
fi
