#!/usr/bin/env bash
source dt_utils.sh


API_REQS_TXT=$F_DA/requirements_api.txt



function install_api {
    _pb "INSTALL API"
     cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    _pb "virtualenv API removing"
    rm -rf "$FOL_VEN" 2> /dev/null
    python3 -m venv "$FOL_VEN" && \
    source "$FOL_VEN"/bin/activate && \
    "$VPIP" install --upgrade pip && \
    "$VPIP" install wheel
    _e $? "cannot create virtualenv"


    _pb "installing API requirements"
    "$VPIP" install -r "$API_REQS_TXT" && \


    _pb "install_api done"
}
