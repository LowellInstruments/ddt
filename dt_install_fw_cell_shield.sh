#!/usr/bin/env bash
source dt_utils.sh


function install_fw_cell_shield {
    title dt_install_fw_cell_shield

    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)

    _py "------------------------------"
    _py "remember check firmware shield"
    _py "see ddt/README.md for details"
    _py "------------------------------"
}

if [ "$1" == "force" ]; then install_fw_cell_shield; fi

