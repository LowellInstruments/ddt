#!/usr/bin/env bash
source dt_utils.sh


function install_api {
    title dt_install_api
     cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    _pb "virtualenv API removing, folder $FOL_VAN"
    rm -rf "$FOL_VAN" 2> /dev/null


    _pb "virtualenv API creating"
    python3 -m venv "$FOL_VAN" && \
    source "$FOL_VAN"/bin/activate && \
    "$VPAP" install --upgrade pip && \
    "$VPAP" install wheel
    _e $? "cannot create virtualenv"


    _pb "installing API requirements"
    "$VPAP" install -r "$FOL_DDH"/requirements_api.txt
    _e $? "cannot pip install api_reqs_txt"
}
