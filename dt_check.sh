#!/usr/bin/env bash


FOL=/home/pi/li/ddt
if [ "$(pwd)" != $FOL ]; then
    echo "error dt_check: working_dir should be $FOL"
    exit 1
fi


grep 2023 /boot/issue.txt
rv=$?
if [ $rv -ne 0 ]; then
    # example: Raspberry Pi reference 2023-05-03
    echo "-----------------------------"
    echo "warning: this DDH is not 2023"
    echo "-----------------------------"
fi
