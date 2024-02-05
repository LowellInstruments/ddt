#!/usr/bin/env bash
source dt_utils.sh



function install_bluez {
    title dt_install_linux_bluez

    _pb "INSTALL LINUX BLUEZ"
     cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    grep Raspberry /proc/cpuinfo
    rv=$?
    if [ $rv -eq 0 ]; then
        _pb "btuart"
        sudo cp _dt_files/btuart /usr/bin/ && \
        sudo chown root /usr/bin/btuart && \
        sudo chgrp root /usr/bin/btuart
        _e $? "btuart patch for rpi"
    fi

    _pb "bluez"
    cd _dt_files && \
    wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.66.tar.xz
    _e $? "download bluez"
    unxz bluez-5.66.tar.xz && \
    tar xvf bluez-5.66.tar
    _e $? "uncompress bluez"
    cd bluez-5.66 && \
    ./configure && \
    make && \
    sudo make install && \
    rm -rf bluez-5.66*
    _e $? "install bluez"
}

