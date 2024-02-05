#!/usr/bin/env bash
source dt_utils.sh


# --------------------------------------------------
# creates flags that other installers rely upon
# also affects global file upload behavior
# --------------------------------------------------

function install_custom {
    title dt_install_custom_box

    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)

    _pb "CUSTOMIZING BOX"
    _pb "creating $FOL_LI"
    mkdir "$FOL_LI" 2> /dev/null

    _pb "removing custom flags"
    rm "$EMOLT_FILE_FLAG" 2> /dev/null
    rm "$GROUPED_S3_FILE_FLAG" 2> /dev/null

    read -rp "Set this DDH as emolt? (y/n) " choice
    # affects dt_install_linux.sh /rc.local juice4halt, net switching service...
    case "$choice" in
        y|Y ) touch "$EMOLT_FILE_FLAG"; printf 'set emolt OK\n';;
    esac
    read -rp "Set this DDH with grouped S3 uplink? (y/n) " choice
    # how DDH groups files before S3 upload
    case "$choice" in
        y|Y ) touch "$GROUPED_S3_FILE_FLAG"; printf 'set grouped S3 OK\n';;
    esac
}
