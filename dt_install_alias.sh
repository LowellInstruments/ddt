#!/usr/bin/env bash
source dt_utils.sh
title dt_install_alias



F_IN=/usr/local/bin
F_RC=/home/pi/.bashrc


function install_alias {
    _pb "INSTALL ALIAS"
    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    _pb "climenu build"
    gcc "$FOL_DDT"/_dt_files/climenu.c -o "$FOL_DDT"/_dt_files/cm
    _e $? "building climenu"


    _pb "climenu install"
    sudo killall cm 2> /dev/null
    sudo cp "$FOL_DDT"/_dt_files/cm $F_IN && \
    sudo cp "$FOL_DDT"/_dt_files/cmc.conf /etc/ && \
    sudo cp "$FOL_DDT"/_dt_files/cmi.conf /etc/
    _e $? "copy alias"


    _pb "climenu alias"
    grep 'alias ddc' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo 'alias ddc="/usr/local/bin/cm /etc/cmc.conf"' >> $F_RC
    fi
    grep 'alias ddi' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo 'alias ddi="/usr/local/bin/cm /etc/cmi.conf"' >> $F_RC
    fi
    sudo chmod +x $F_IN/cm
    _e $? "install alias"
}


if [ "$1" == "force" ]; then install_alias; fi
