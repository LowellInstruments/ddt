#!/usr/bin/env bash


# grab vars from other script
. ./dt_variables.sh || (echo 'fail dt_vars'; exit 1)


ping -q -c 1 -W 1 www.google.com
rv=$?
if [ $rv -eq 0 ]; then
    echo;  echo 'R > we have internet, updating...'
    "$F_DT"/dt_install_python_mat.sh
    "$F_DT"/dt_install_python_ddh.sh
else
    echo; echo 'R > NO internet, NO updating'
fi
