#!/usr/bin/env bash

F_LI=/home/pi/li

function install_fw_cell_shield {
    source dt_utils.sh
    cd $F_LI || (_pe "error: bad working directory"; exit 1)

    _pr "------------------------------"
    _pr "remember check firmware shield"
    _pr "see ddt/README.md for details"
    _pr "------------------------------"
}
