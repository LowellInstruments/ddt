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



    read -rp "Set this DDH with grouped S3 uplink? (y/n) " choice
    # how DDH groups files before S3 upload
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


    read -rp "Does this DDH use sailor hat shield? (y/n) " choice
    case "$choice" in
        y|Y ) touch "$DDH_USES_SHIELD_SAILOR"; printf 'set sailor shield flag OK\n';;
    esac

}
