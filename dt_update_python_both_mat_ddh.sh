#!/usr/bin/env bash


FT=/home/pi/li/ddt


ping -q -c 1 -W 1 www.google.com
rv=$?
if [ $rv -eq 0 ]; then
    echo;  echo 'R > we have internet, updating...'
    $FT/dt_install_python_mat.sh
    $FT/dt_install_python_ddh.sh
else
    echo; echo 'R > NO internet, NO updating'
fi