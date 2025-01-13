#!/usr/bin/env bash
source dt_utils.sh


function install_power {
    title dt_install_power

    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)

    _pb "removing custom flags"
    rm "$DDH_USES_SHIELD_JUICE4HALT" 2> /dev/null
    rm "$DDH_USES_SHIELD_SAILOR" 2> /dev/null



    read -rp "Does this DDH use juice_for_halt shield? (y/n) " choice
    case "$choice" in
        y|Y ) touch "$DDH_USES_SHIELD_JUICE4HALT"; printf 'set j4h shield flag OK\n';;
    esac


    # omit if we already know we are using J4H
    if [ "$choice" != 'y' ] && [ "$choice" != 'Y' ]; then
        read -rp "Does this DDH use sailor hat shield? (y/n) " choice
        case "$choice" in
            y|Y ) touch "$DDH_USES_SHIELD_SAILOR"; printf 'set sailor shield flag OK\n';;
        esac
    fi



    # install stuff only on pure LI DDH such as wiringpi and juice4halt
    J4H="$FOL_LI"/juice4halt
    sudo rm -rf "$J4H"
    if [ -f "$DDH_USES_SHIELD_JUICE4HALT" ]; then
        _pb "juice4halt"
        # wiringpi is already going to be installed by ppp_install_*.sh
        # sudo dpkg -i ./_dt_files/wiringpi-latest.deb
        mkdir -p "$J4H"/bin
        cp "$FOL_DDT"/_dt_files/shutdown_script.py "$J4H"/bin/
        cp "$FOL_DDT"/_dt_files/popup_j4h.sh "$J4H"/bin/
        _e $? "juice4halt"

        # just in case
        sudo systemctl disable shrpid
        sudo systemctl stop shrpid
    fi


    # install sailor_hat shield
    if [ -f "$DDH_USES_SHIELD_SAILOR" ]; then
        sudo rm -rf "$J4H"


        _pb "unzipping sailorhat folder"
        FOL_TMP_SAH=/tmp/my_sailorhat
        rm -rf $FOL_TMP_SAH 2> /dev/null
        unzip "$FOL_DDT"/_dt_files/sh_rpi_daemon_224.zip -d $FOL_TMP_SAH
        _e $? "unzipping sailor_hat"


        _pb "modifying sailorhat couple of files"
        cp "$FOL_DDT"/_dt_files/sailor_const.py $FOL_TMP_SAH/SH-RPi-daemon-2.2.4/src/shrpi/const.py
        cp "$FOL_DDT"/_dt_files/sailor_sm.py $FOL_TMP_SAH/SH-RPi-daemon-2.2.4/src/shrpi/state_machine.py
        _e $? "modifying sailor_hat"


        _pb "installing modified sailorhat"
        cd $FOL_TMP_SAH/SH-RPi-daemon-2.2.4 && \
        sudo ./install.sh --enable RTC
        _e $? "installing sailor_hat"


        _pb 'creating sailor_hat pop-up'
        FOL_SAH="$FOL_LI"/sailorhat
        rm -rf "$FOL_SAH" 2> /dev/null
        mkdir "$FOL_SAH"
        sudo cp "$FOL_DDT"/_dt_files/popup_sah.sh "$FOL_SAH"
        _e $? "sailor_hat pop-up"



        _pb "checking sailor_hat service active"
        sudo systemctl enable shrpid
        sudo systemctl start shrpid
        sudo systemctl is-active shrpid.service | grep -w active
        _e $? "sailor_hat service NOT active"
    fi
}

if [ "$1" == "force" ]; then install_power; fi

