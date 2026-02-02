#!/usr/bin/env bash
source dt_utils.sh



function install_step_6 {

    clear
    title dt_install_cell


    _pb "CHECK CELL SHIELD FIRMWARE VERSION"
    source "$FOL_VEN"/bin/activate
    python3 _dt_files/main_detect_cell_hat_fw.py | grep 2022
    _e $? "CELL SHIELD FIRMWARE, see README.md in repository ddt_quectel"

}


# when calling this file
install_step_6
