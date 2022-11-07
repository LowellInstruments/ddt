#!/usr/bin/env bash



# grab vars from other script
. ./_dt_files/dt_variables.sh || (echo 'fail dt_vars'; exit 1)
echo



# see we have internet access
ping -q -c 1 -W 1 www.google.com
rv=$?
if [ $rv -ne 0 ]; then
    echo '[ DDH ] install_all --> NO internet, NO updating'
    exit 1
fi
echo


# comment on RPi, uncomment when testing on laptop
# F_DA=/home/kaz/PycharmProjects/ddx/



# get remote and local commit IDs
printf '\n------ running DDH install_all ------\n\n'
_RCID=$(git ls-remote https://github.com/lowellinstruments/ddx.git master | awk '{ print $1 }')
rv=$?
if [ "$rv" -ne 0 ]; then echo '[ DDH ] error: getting git remote commit ID'; exit 1; fi
if [ ${#_RCID} -ne 40 ]; then echo '[ DDH ] error: bad git remote commit ID'; exit 1; fi


# does the DDH app folder exist
if [ ! -d "$F_DA" ]; then
    printf '[ DDH ] %s folder does not prior exist' "$F_DA"
    exit 2
fi


# get remote and local git commit ID
_LCID=$(cd "$F_DA" && git rev-parse master)
if [ "$rv" -ne 0 ]; then echo '[ DDH ] error: getting git local commit ID'; exit 1; fi
if [ ${#_LCID} -ne 40 ]; then echo '[ DDH ] error: bad git local commit ID'; exit 1; fi
printf '[ DDH ] git remote commit ID %s\n' "$_RCID"
printf '[ DDH ] git local  commit ID %s\n' "$_LCID"


# decide we update or not
if [ "$_RCID" == "$_LCID" ]; then echo '[ DDH ] is up-to-date'; exit 0; fi


# uncomment on RPi, comment when testing on laptop
echo '[ DDH ] needs an update'
"$F_DT"/dt_install_python_mat.sh
"$F_DT"/dt_install_python_ddh.sh
