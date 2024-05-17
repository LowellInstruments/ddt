#!/usr/bin/env bash
source dt_utils.sh



F_IN=/usr/local/bin
F_RC=/home/pi/.bashrc


function install_alias {
    title dt_install_alias

    _pb "INSTALL ALIAS"
    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    _pb "climenu binary build"
    gcc "$FOL_DDT"/_dt_files/climenu.c -o "$FOL_DDT"/_dt_files/cm
    _e $? "building climenu"


    _pb "climenu install"
    sudo killall cm 2> /dev/null
    sudo cp "$FOL_DDT"/_dt_files/cm $F_IN && \
    sudo cp "$FOL_DDT"/_dt_files/cmi.conf /etc && \
    sudo cp "$FOL_DDT"/_dt_files/cmu.conf /etc
    _e $? "copy alias"


    _pb "climenu alias"
    grep 'alias ddc' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias ddc=\"/home/pi/li/ddh/run_ddc.sh\"" >> $F_RC
    fi

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
    _e $? "install alias"

    # ---------------------
    # not used very often
    # ---------------------

    # alias configuration edit
    grep 'alias ace' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias aec=\"nano $FOL_DDH/settings/config.toml\"" >> $F_RC
    fi

    # alias configuration see
    grep 'alias acs' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias acs=\"cat $FOL_DDH/settings/config.toml\"" >> $F_RC
    fi

    # alias cronTab edit
    grep 'alias ate' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias ate=\"sudo nano /etc/crontab\"" >> $F_RC
    fi
}


if [ "$1" == "force" ]; then install_alias; fi
