#!/usr/bin/env bash
source dt_utils.sh



F_IN=/usr/local/bin
F_RC=/home/pi/.bashrc


function install_alias {
    title dt_install_alias

    _pb "INSTALL ALIAS"
    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)



    # convenient aliases
    _pb "alias shortcut"
    grep 'alias cdh' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias cdh=\"cd /home/pi/li/ddh\"" >> $F_RC
    fi
    grep 'alias cdt' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias cdt=\"cd /home/pi/li/ddt\"" >> $F_RC
    fi
    grep 'alias mnc' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias mnc=\"minicom -D /dev/ttyUSB2\"" >> $F_RC
    fi



    _pb "alias ddc"
    sed -i '/alias ddc/d' $F_RC
    grep 'alias ddc' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias ddc=\"/home/pi/li/ddh/run_ddc.sh\"" >> $F_RC
    fi


    _pb "climenu build and install"
    gcc "$FOL_DDT"/_dt_files/climenu.c -o "$FOL_DDT"/_dt_files/cm
    _e $? "climenu build"
    sudo killall cm 2> /dev/null
    sudo cp "$FOL_DDT"/_dt_files/cm $F_IN && \
    sudo cp "$FOL_DDT"/_dt_files/cmi.conf /etc && \
    sudo cp "$FOL_DDT"/_dt_files/cmu.conf /etc
    _e $? "climenu install"



    _pb "alias climenu ddi, ddu"
    grep 'alias ddi' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias ddi=\"$F_IN/cm /etc/cmi.conf\"" >> $F_RC
    fi
    grep 'alias ddu' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias ddu=\"$F_IN/cm /etc/cmu.conf\"" >> $F_RC
    fi
    sudo chmod +x $F_IN/cm
    _e $? "install climenu alias"
}


if [ "$1" == "force" ]; then install_alias; fi
