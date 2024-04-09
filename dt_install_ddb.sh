#!/usr/bin/env bash
source dt_utils.sh


function install_ddb {
    title dt_install_ddb
     cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    _pb "virtualenv DDB removing, folder $FOL_VBN"
    rm -rf "$FOL_VBN" 2> /dev/null


    _pb "virtualenv DDB creating"
    python3 -m venv "$FOL_VBN" && \
    source "$FOL_VBN"/bin/activate && \
    "$VPAP" install --upgrade pip && \
    "$VPAP" install wheel
    _e $? "cannot create virtualenv DDB"


    _pb "installing DDB requirements"
    "$VPAP" install -r "$FOL_DDH"/ddb/requirements.txt
    _e $? "cannot pip install ddb requirements"
}

if [ "$1" == "force" ]; then install_ddb; fi

