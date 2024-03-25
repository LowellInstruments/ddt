#!/usr/bin/env bash
source dt_utils.sh



function install_check {
    title dt_check

    if [ "$(pwd)" != "$FOL_DDT" ]; then
        _pr "error dt_check: working_dir should be $FOL"
        exit 1
    fi

    # get raspberry hardware version
    grep "Pi 3" /proc/cpuinfo
    is_rpi3=$?

    # get OS release version
    grep "2023-05-03" /boot/issue.txt
    is_202305=$?

    # check bad combinations
    if [ "$is_rpi3" -eq 0 ] && [ "$is_202305" -ne 0 ]; then
        _pr "DDH can only run on raspberryos 202305 release for rpi3"
        exit 1
    fi
}