#!/usr/bin/env bash


# --------------------------------------------------
# creates flags that other installers rely upon
# also affects global file upload behavior
# --------------------------------------------------

FOL=/home/pi/li
EMOLT_FILE_FLAG=$FOL/.ddt_this_is_emolt_box.flag
GROUPED_S3_FILE_FLAG=$FOL/.ddt_this_box_has_grouped_s3_uplink.flag


function install_custom {
    source dt_utils.sh
    cd $FOL || (_pe "error: bad working directory"; exit 1)

    _pb "CUSTOMIZING BOX"
    _pb "creating $FOL"
    mkdir $FOL 2> /dev/null

    _pb "removing custom flags"
    rm $EMOLT_FILE_FLAG 2> /dev/null
    rm $GROUPED_S3_FILE_FLAG 2> /dev/null

    read -rp "Set this DDH as emolt? (y/n) " choice
    # affects dt_install_linux.sh /rc.local juice4halt, net switching service...
    case "$choice" in
        y|Y ) touch $EMOLT_FILE_FLAG; printf 'set emolt OK\n';;
    esac
    read -rp "Set this DDH with grouped S3 uplink? (y/n) " choice
    # how DDH groups files before S3 upload
    case "$choice" in
        y|Y ) touch $GROUPED_S3_FILE_FLAG; printf 'set grouped S3 OK\n';;
    esac
}
