#!/usr/bin/env bash
source dt_utils.sh






function install_extra {
    title dt_install_extra

    _pb "INSTALL EXTRA"
}


if [ "$1" == "force" ]; then install_extra; fi
