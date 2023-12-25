#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt
F_IN=/usr/local/bin
F_RC=/home/pi/.bashrc


function install_alias {
    source dt_utils.sh
    _pb "INSTALL ALIAS"

    gcc $F_DT/_dt_files/climenu.c -o $F_DT/_dt_files/cm
    _e $? "building climenu"

    sudo killall cm 2> /dev/null
    sudo cp $F_DT/_dt_files/cm $F_IN && \
    sudo cp $F_DT/_dt_files/cmc.conf /etc/ && \
    sudo cp $F_DT/_dt_files/cmi.conf /etc/
    _e $? "copy alias"

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
