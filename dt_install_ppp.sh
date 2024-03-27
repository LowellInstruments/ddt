#!/usr/bin/env bash
source dt_utils.sh


function install_ppp {

    title dt_install_ppp

    # cell shield existence or not :)
    read -rp "Will this box use cell shield? (y/n) " choice
    case "$choice" in
        n|N ) printf 'not installing cell shield'; return 0;;
    esac

    sudo "$FOL_DDT"/_dt_files/ppp_install_custom.sh
}

if [ "$1" == "force" ]; then install_ppp; fi

