#!/usr/bin/env bash
source dt_utils.sh



GH_REPO_MAT=https://github.com/lowellinstruments/mat.git
GH_REPO_DDH=https://github.com/lowellinstruments/ddh.git
F_CLONE_MAT=/tmp/mat
F_CLONE_DDH=/tmp/ddh
WHEEL_DBUS=$FOL_DDT/_dt_files/my_wheels/dbus_fast-2.21.1-cp311-cp311-manylinux_2_36_aarch64.whl


function install_ddh {
    title dt_install_ddh


    _pb "INSTALL DDH"
     cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)



    _pb "[  5% ] DDH folder detection"
    ! test -d "$FOL_DDH"
    _e $? "DDH folder already exists"


    _pb "[ 10% ] kill DDH processes"
    killall main_ddh main_ddh_controller \
    main_dds main_dds_controller 2> /dev/null


    _pb "[ 15% ] internet detection"
    ping -q -c 1 -W 2 www.google.com
    _e $? "no internet"


    # virtualenv
    _pb "[ 20% ] virtualenv removing"
    rm -rf "$FOL_VEN" 2> /dev/null
    rm -rf "$HOME"/.cache/pip 2> /dev/null
    _pb "[ 22% ] virtualenv creating"
    python3 -m venv "$FOL_VEN" --system-site-packages && \
    source "$FOL_VEN"/bin/activate && \
    "$VPIP" install --upgrade pip && \
    "$VPIP" install wheel
    _e $? "cannot create virtualenv"


    _pb "[ 25% ] MAT library"
    rm -rf $F_CLONE_MAT 2> /dev/null
    git clone $GH_REPO_MAT $F_CLONE_MAT
    cp $F_CLONE_MAT/tools/_setup_wo_reqs.py $F_CLONE_MAT/setup.py
    "$VPIP" install $F_CLONE_MAT
    _e $? "cannot install MAT library"


    _pb " [39% ] DDH requirements"
    DDH_TMP_REQS_TXT=$F_CLONE_DDH/requirements_rpi_39_2023.txt
    python3 --version | grep "3.11"
    rv=$?
    if [ $rv -eq 0 ]; then
        DDH_TMP_REQS_TXT=$F_CLONE_DDH/requirements_rpi_311_2023.txt
    fi
    _pb "selected requirements file $DDH_TMP_REQS_TXT"


    # ----------------------------------
    # todo: REMOVE BRANCH TOML here
    # ----------------------------------
    _pb "[ 40% ] DDH source code"
    # todo: test this wheel thing
    rm -rf $F_CLONE_DDH 2> /dev/null
    git clone --branch toml $GH_REPO_DDH $F_CLONE_DDH && \
    "$VPIP" install "$WHEEL_DBUS" && \
    "$VPIP" install -r $DDH_TMP_REQS_TXT && \
    mv "$F_CLONE_DDH" "$FOL_LI"
    _e $? "cannot install DDH"


    _pb "[ 90% ] setting and protecting file resolv.conf"
    sudo chattr -i /etc/resolv.conf && \
    sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf" && \
    sudo sh -c "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf" && \
    sudo chattr +i /etc/resolv.conf
    _e $? "cannot install new resolv.conf"



    _pb "[ 100% ] install_ddh done"
}

if [ "$1" == "force" ]; then install_ddh; fi
