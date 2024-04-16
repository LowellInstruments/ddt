#!/usr/bin/env bash
source dt_utils.sh



function install_check {
    title dt_check

    if [ "$(pwd)" != "$FOL_DDT" ]; then
        _pr "error dt_check: working_dir should be $FOL"
        exit 1
    fi

    # check editions
    grep "2022-09-22" /boot/issue.txt
    is_202209=$?
    grep "2023-05-03" /boot/issue.txt
    is_202305=$?
    grep "2024-03-15" /boot/issue.txt
    is_202403=$?

    # check bad combinations
    if [ "$is_202209" -ne 0 ] && \
       [ "$is_202305" -ne 0 ] && \
       [ "$is_202403" -ne 0 ]; then
        _pr "DDH detected unknown raspberryOS edition"
        exit 1
    fi

    # show architecture
    arch
}

if [ "$1" == "force" ]; then install_check; fi

