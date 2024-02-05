#!/usr/bin/env bash
source dt_utils.sh


function install_ppp {

    title dt_install_ppp

    # cell shield existence or not :)
    if [ -f "$EMOLT_FILE_FLAG" ]; then
        read -rp "Will this emolt_DDH use cell shield? (y/n) " choice
        case "$choice" in
            n|N ) printf 'not installing cell shield'; return 0;;
        esac
    fi

    sudo "$FOL_DDT"/_dt_files/ppp_install_custom.sh

}
