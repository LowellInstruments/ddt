#!/usr/bin/env bash
source dt_utils.sh


API_REQS_TXT=$F_DA/requirements_api.txt



function install_api {
    title dt_install_api
     cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    _pb "virtualenv API removing, folder $FOL_VAN"
    rm -rf "$FOL_VAN" 2> /dev/null
    python3 -m venv "$FOL_VAN" && \
    source "$FOL_VAN"/bin/activate && \
    "$VPIP" install --upgrade pip && \
    "$VPIP" install wheel
    _e $? "cannot create virtualenv"


    _pb "installing API requirements"
    "$VPIP" install -r "$API_REQS_TXT"
    _e $? "cannot pip install api_reqs_txt"
}
