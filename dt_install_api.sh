#!/usr/bin/env bash


F_LI=/home/pi/li
F_DA="$F_LI"/ddh
F_VE="$F_LI"/venv_api
VPIP=$F_VE/bin/pip
API_REQS_TXT=$F_DA/requirements_api.txt


function install_api {
    source dt_utils.sh
    _pb "INSTALL API"
     cd $F_LI || (_pe "error: bad working directory"; exit 1)


    _pb "virtualenv API removing"
    rm -rf "$F_VE" 2> /dev/null
    python3 -m venv "$F_VE" && \
    source "$F_VE"/bin/activate && \
    "$VPIP" install --upgrade pip && \
    "$VPIP" install wheel
    _e $? "cannot create virtualenv"


    _pb "installing API requirements"
    "$VPIP" install -r $API_REQS_TXT && \


    _pb "install_api done"
}
