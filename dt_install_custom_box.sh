#!/usr/bin/env bash
source dt_utils.sh


# ---------------------------------------------------
# CREATES flags that tools such as DDC read and write
# ----------------------------------------------------

function install_custom {
    title dt_install_custom_box

    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)

    _pb "CUSTOMIZING BOX"
    _pb "creating $FOL_LI"
    mkdir "$FOL_LI" 2> /dev/null


    _pb "removing custom flags"
    rm "$GROUPED_S3_FILE_FLAG" 2> /dev/null
    rm "$GPS_EXTERNAL_FILE_FLAG" 2> /dev/null
    rm "$DDH_USES_SHIELD_CELL" 2> /dev/null
    rm "$DDH_USES_SHIELD_JUICE4HALT" 2> /dev/null
    rm "$DDH_USES_SHIELD_SAILOR" 2> /dev/null



    # how DDH groups files before S3 upload
    read -rp "Set this DDH with grouped S3 uplink? (y/n) " choice
    case "$choice" in
        y|Y ) touch "$GROUPED_S3_FILE_FLAG"; printf 'set grouped S3 flag OK\n';;
    esac


    read -rp "Set this DDH with external GPS puck? (y/n) " choice
    case "$choice" in
        y|Y ) touch "$GPS_EXTERNAL_FILE_FLAG"; printf 'set GPS puck flag OK\n';;
    esac


    read -rp "Does this DDH use cell shield? (y/n) " choice
    case "$choice" in
        y|Y ) touch "$DDH_USES_SHIELD_CELL"; printf 'set cell shield flag OK\n';;
    esac


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
        # wiringpi is already going to be installed by ppp_install_standalone.sh
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
    SAH="$FOL_LI"/sailorhat
    if [ -f "$DDH_USES_SHIELD_SAILOR" ]; then
        _pb "shield sailor_hat, please enter answers as follows"
        _pb "    - enable on-board RTC"
        _pb "    - disable CAN interface"
        _pb "    - disable RS485 interface"
        _pb "    - disable MAX-M8Q GNSS interface"
        _pb
        read -r
        sudo rm -rf "$J4H"
        pip uninstall shrpi --break-system-packages
        curl -L \
        https://raw.githubusercontent.com/hatlabs/SH-RPi-daemon/main/install-online.sh \
        | sudo bash
        _e $? "sailor_hat install"

        _pb 'modifying sailor_hat settings'
        vv=$(python -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
        c_sailor_p=/usr/local/lib/shrpid/lib/python"$vv"/site-packages/shrpi/
        sudo cp "$FOL_DDT"/_dt_files/sailor_const.py "$c_sailor_p"/const.py
        sudo cp "$FOL_DDT"/_dt_files/sailor_sm.py "$c_sailor_p"/state_machine.py

        mkdir "$SAH"
        sudo cp "$FOL_DDT"/_dt_files/popup_sah.sh "$SAH"
        _e $? "sailor_hat modifying settings"


        _pb "checking sailor_hat service active"
        sudo systemctl enable shrpid
        sudo systemctl start shrpid
        sudo systemctl is-active shrpid.service | grep -w active
        _e $? "sailor_hat service NOT active"
    fi
}

if [ "$1" == "force" ]; then install_custom; fi

