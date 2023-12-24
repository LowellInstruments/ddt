#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt


function install_bluez {
    source dt_install_utils.sh
    _pb "INSTALL LINUX BLUEZ"

    grep Raspberry /proc/cpuinfo
    rv=$?
    if [ $rv -eq 0 ]; then
        sudo cp _dt_files/btuart /usr/bin/ && \
        sudo chown root /usr/bin/btuart && \
        sudo chgrp root /usr/bin/btuart
        _e $? "btuart patch for rpi"
    fi


    cd _dt_files && \
    wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.66.tar.xz
    _e $? "download bluez"
    unxz bluez-5.66.tar.xz && \
    tar xvf bluez-5.66.tar
    _e $? "uncompress bluez"


    cd bluez-5.66 && \
    ./configure && \
    make && \
    sudo make install
    _e $? "install bluez"
}
