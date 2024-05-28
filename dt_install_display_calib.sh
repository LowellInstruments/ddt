#!/usr/bin/env bash
source dt_utils.sh



function install_display_calib {
    title dt_install_display_calib

    echo "you can switch from Wayland to X11 by doing"
    echo "    sudo raspi-config"
    echo "and going to option  6 / A6"
}

if [ "$1" == "force" ]; then install_display_calib; fi

