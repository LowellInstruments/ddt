#!/usr/bin/env bash



# grab vars from other script
. ./_dt_files/dt_variables.sh || (echo 'fail dt_vars'; exit 1)
echo



# see we have internet access
ping -q -c 1 -W 1 www.google.com
rv=$?
if [ $rv -ne 0 ]; then
    echo 'U > NO internet, NO updating'
    exit 1
fi
echo


# comment on RPi, uncomment when testing on laptop
# F_DA=/home/kaz/PycharmProjects/ddx/



# get remote and local commit IDs
_RCID=$(git ls-remote https://github.com/lowellinstruments/ddx.git master | awk '{ print $1 }')
if [ $? -ne 0 ]; then echo 'U > error doing remote ID'; exit 1; fi
if [ ${#_RCID} -ne 40 ]; then echo 'U > bad remote ID'; exit 1; fi
_LCID=$(cd $F_DA && git rev-parse master)
if [ $? -ne 0 ]; then echo 'U > error doing local ID'; exit 1; fi
if [ ${#_LCID} -ne 40 ]; then echo 'U > bad local ID'; exit 1; fi
printf 'U > DDH last remote commit ID %s\n' $_RCID
printf 'U > DDH last local  commit ID %s\n' $_LCID



# update or not
if [ $_RCID == $_LCID ]; then
    echo 'U > DDX has the latest version'
    exit 0
fi
echo 'U > warning: DDX local commit != remote'



# uncomment on RPi, comment when testing on laptop
"$F_DT"/dt_install_python_mat.sh
"$F_DT"/dt_install_python_ddh.sh


