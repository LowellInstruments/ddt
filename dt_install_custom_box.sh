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
    rm "$DDH_USES_SHIELD_CELL_SIXFAB" 2> /dev/null
    rm "$DDH_USES_SHIELD_CELL_TWILIO" 2> /dev/null
    rm "$DDH_USES_SHIELD_JUICE4HALT" 2> /dev/null
    rm "$DDH_USES_SHIELD_SAILOR" 2> /dev/null



    # how DDH groups files before S3 upload
    echo
    read -rp "Set this DDH with grouped S3 uplink? (y/n) " choice
    case "$choice" in
        y|Y ) touch "$GROUPED_S3_FILE_FLAG"; printf 'set grouped S3 flag OK\n';;
    esac


    echo
    read -rp "Set this DDH with external GPS puck? (y/n) " choice
    case "$choice" in
        y|Y ) touch "$GPS_EXTERNAL_FILE_FLAG"; printf 'set GPS puck flag OK\n';;
    esac



    echo
    read -rp "Does this DDH use a cell shield with TWILIO SIM? (y/n) " choice
    case "$choice" in
        y|Y ) touch "$DDH_USES_SHIELD_CELL_TWILIO"; printf 'set cell shield with twilio flag OK\n';;
    esac


    echo
    read -rp "Does this DDH use a cell shield with SIXFAB SIM? (y/n) " choice
    case "$choice" in
        y|Y ) touch "$DDH_USES_SHIELD_CELL_SIXFAB"; printf 'set cell shield with sixfab flag OK\n';;
    esac
}

if [ "$1" == "force" ]; then install_custom; fi

