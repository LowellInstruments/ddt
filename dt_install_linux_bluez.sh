#!/usr/bin/env bash
source dt_utils.sh



function install_bluez {
    title dt_install_linux_bluez

    _pb "INSTALL LINUX BLUEZ"
     cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    # this seems to minimize the number of BLE hardware errors
    grep Raspberry /proc/cpuinfo
    rv=$?
    if [ $rv -eq 0 ]; then
        _pb "btuart"
        sudo cp "$FOL_DDT"/_dt_files/btuart /usr/bin/ && \
        sudo chown root /usr/bin/btuart && \
        sudo chgrp root /usr/bin/btuart
        _e $? "btuart patch for rpi"
    fi


    # 5.66 version seems to work nicely with bleak BLE library
    _pb "checking current bluez version"
    bluetoothctl -v | grep "5.66"
    rv=$?
    if [ $rv -eq 0 ]; then
        _pg "bluez already version 5.66"
    else
        _pb "bluez"
        cd "$FOL_DDT"/_dt_files && \
        wget -O bluez-5.66.tar.xz http://www.kernel.org/pub/linux/bluetooth/bluez-5.66.tar.xz
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
    fi
}

if [ "$1" == "force" ]; then install_bluez; fi
