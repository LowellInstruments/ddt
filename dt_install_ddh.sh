#!/usr/bin/env bash


source dt_utils.sh


F_LI=/home/pi/li
F_DA="$F_LI"/ddh
F_VE="$F_LI"/venv
VPIP=$F_VE/bin/pip
GH_REPO_MAT=https://github.com/lowellinstruments/mat.git
GH_REPO_DDH=https://github.com/lowellinstruments/ddh.git
F_CLONE_MAT=/tmp/mat
F_CLONE_DDH=/tmp/ddh
DDH_REQS_TXT=$F_DA/requirements_rpi_39.txt


function install_ddh {
    source dt_utils.sh
    _pb "INSTALL DDH"


    _pb "[ 05% ] DDH folder detection"
    ! test -d "$F_DA"
    _e $? "DDH folder already exists"


    _pb "[ 10% ] kill DDH processes"
    killall main_ddh main_ddh_controller \
    main_dds main_dds_controller 2> /dev/null


    _pb "[ 15% ] internet detection"
    ping -q -c 1 -W 2 www.google.com
    _e $? "no internet"


    # virtualenv
    _pb "[ 20% ] virtualenv"
    rm -rf "$F_VE" 2> /dev/null
    rm -rf "$HOME"/.cache/pip 2> /dev/null
    python3 -m venv "$F_VE" --system-site-packages && \
    source "$F_VE"/bin/activate && \
    "$VPIP" install --upgrade pip && \
    "$VPIP" install wheel
    _e $? "cannot create virtualenv"


    _pb "[ 25% ] MAT library"
    rm -rf $F_CLONE_MAT 2> /dev/null
    git clone $GH_REPO_MAT $F_CLONE_MAT
    cp $F_CLONE_MAT/tools/_setup_wo_reqs.py $F_CLONE_MAT/setup.py
    "$VPIP" install $F_CLONE_MAT
    _e $? "cannot install MAT library"


    _pb "[ 40% ] DDH source code"
    git clone $GH_REPO_DDH $F_CLONE_DDH && \
    "$VPIP" install -r "$F_CLONE_DDH"/$DDH_REQS_TXT && \
    mv "$F_CLONE_DDH" "$F_LI"
    _e $? "cannot install DDH"


    _pb "[ 90% ] resolv.conf"
    sudo chattr -i /etc/resolv.conf && \
    sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf" && \
    sudo sh -c "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf" && \
    sudo chattr +i /etc/resolv.conf
    _e $? "cannot install new resolv.conf"


    _pb "[ 100% ] done"
}
