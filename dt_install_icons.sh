#!/usr/bin/env bash
source dt_utils.sh



function install_icons {
    title dt_install_icons

    _pb "INSTALL ICONS"
    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    cp "$FOL_DDT"/_dt_files/crontab_ddh.sh /home/pi/Desktop/DDH.sh
    cp "$FOL_DDT"/_dt_files/run_ddc_from_desktop.sh /home/pi/Desktop/DDC.sh
    _e $? "install_icons"
}


if [ "$1" == "force" ]; then install_icons; fi

