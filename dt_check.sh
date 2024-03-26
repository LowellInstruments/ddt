#!/usr/bin/env bash
source dt_utils.sh



function install_check {
    title dt_check

    if [ "$(pwd)" != "$FOL_DDT" ]; then
        _pr "error dt_check: working_dir should be $FOL"
        exit 1
    fi

    # grep raspberry architecture, hardware version and OS version
    arch | grep "armv7l"
    is_arm7=$?
    grep "Pi 3" /proc/cpuinfo
    is_rpi3=$?
    grep "2023-05-03" /boot/issue.txt
    is_202305=$?

    # check bad combinations
    if [ "$is_rpi3" -eq 0 ]; then
        if [ "$is_202305" -ne 0 ] || [ $is_arm7 -ne 0 ]; then
            _pr "DDH can only run on raspberryos 202305 armv7l release for rpi3"
            exit 1
        fi
    fi
}
