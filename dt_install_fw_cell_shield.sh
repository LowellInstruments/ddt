#!/usr/bin/env bash
source dt_utils.sh


function install_fw_cell_shield {
    title dt_install_fw_cell_shield

    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)

    _pr "------------------------------"
    _pr "remember check firmware shield"
    _pr "see ddt/README.md for details"
    _pr "------------------------------"
}
