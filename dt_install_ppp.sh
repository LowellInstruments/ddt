#!/usr/bin/env bash
source dt_utils.sh


function install_ppp {

    title dt_install_ppp


    if [ -f "$DDH_USES_SHIELD_CELL_SIXFAB" ]; then
        sudo "$FOL_DDT"/_dt_files/ppp_install_sixfab.sh
    elif [ -f "$DDH_USES_SHIELD_CELL_TWILIO" ]; then
        sudo "$FOL_DDT"/_dt_files/ppp_install_twilio.sh
    fi
}

if [ "$1" == "force" ]; then install_ppp; fi

