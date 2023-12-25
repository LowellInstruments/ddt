#!/usr/bin/env bash


F_DT=/home/pi/li/ddt

function install_icons {
    source dt_utils.sh
    _pb "INSTALL ICONS"

    cp "$F_DT"/_dt_files/run_ddh_from_desktop.sh /home/pi/Desktop
    _e $? "install_icons"
}
