#!/usr/bin/env bash


source dt_utils.sh

FOL=/home/pi/li/ddt

if [ "$(pwd)" != $FOL ]; then
    _pr "error dt_check: working_dir should be $FOL"
    exit 1
fi


grep 2023 /boot/issue.txt
rv=$?
if [ $rv -ne 0 ]; then
    # example: Raspberry Pi reference 2023-05-03
    _py "-----------------------------"
    _py "warning: this DDH is not 2023"
    _py "-----------------------------"
fi
