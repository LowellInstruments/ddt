#!/usr/bin/env bash


export FOL_PI=/home/pi
export FOL_LI=$FOL_PI/li
export FOL_DDH=$FOL_LI/ddh
export FOL_VEN=$FOL_LI/venv
export FOL_VAN=$FOL_LI/venv_api
export VPIP=$FOL_VEN/bin/pip
export VPAP=$FOL_VAN/bin/pip
export FOL_DDT=$FOL_LI/ddt
export EMOLT_FILE_FLAG=$FOL_LI/.ddt_this_is_emolt_box.flag
export GROUPED_S3_FILE_FLAG=$FOL_LI/.ddt_this_box_has_grouped_s3_uplink.flag



# 0 black, 1 red, 2 green, 3 yellow
# 4 blue, 5 magenta, 6 cyan, 7 white
function _p_color { tput setaf "$1"; printf "%s\n" "$2"; tput sgr0; }
function _pr { _p_color 1 "$1"; }
function _pg { _p_color 2 "$1"; }
function _py { _p_color 3 "$1"; }
function _pb { _p_color 6 "$1"; }
function _e {
    if [ "$1" -ne 0 ]; then
        _pr "error: $2 rv $1"; exit "$1";
    fi
}


function title {
    echo
    _pb "####################################"
    _pb "running $1"
    _pb "####################################"
    echo
}
