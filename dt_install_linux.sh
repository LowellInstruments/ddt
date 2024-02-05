#!/usr/bin/env bash
source dt_utils.sh
title dt_install_linux




J4H="$FOL_LI"/juice4halt


function install_linux {
    _pb "INSTALL LINUX DEPENDENCIES"
    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)

    _pb "apt-get"
    sudo apt-get --yes update
    sudo apt-mark hold bluez
    sudo apt remove -y modemmanager
    sudo apt remove -y python3-numpy
    sudo apt-get --yes --force-yes install minicom xscreensaver matchbox-keyboard ifmetric joe git \
    libatlas3-base libglib2.0-dev python3-pyqt5 libhdf5-dev python3-dev \
    libgdal-dev libproj-dev proj-data proj-bin python3-gdbm python3-venv \
    libcurl4-gnutls-dev gnutls-dev python3-pycurl libdbus-1-dev libopenblas-dev \
    libudev-dev libical-dev libreadline-dev libcap-dev awscli python3-requests ninja-build wireguard
    _e $? "apt-get"


    # only required for some DDT conf scripts
    _pb "pip"
    pip install getmac
    _e $? "pip"


    # install stuff only on pure LI DDH such as wiringpi and juice4halt
    if [ ! -f $EMOLT_FILE_FLAG ]; then
        _pb "juice4halt"
        # already done by ppp_install_standalone.sh
        # printf '\n\n>>> installing wiringpi\n'
        # sudo dpkg -i ./_dt_files/wiringpi-latest.deb
        sudo rm -rf "$J4H"
        mkdir -p "$J4H"/bin
        cp "$FOL_DDT"/_dt_files/shutdown_script.py "$J4H"/bin/
        _e $? "juice4halt"
    fi


    _pb 'apt-get clean'
    sudo apt autoremove -y
    sudo apt-get clean

    # install a nice wallpaper
    # todo ---> test this
    export XAUTHORITY=/home/pi/.Xauthority
    export DISPLAY=:0
    pcmanfm --set-wallpaper "$FOL_DDT"/_dt_files/wp_ddh.jpg


    # rc.local runs display brightness, NTP, juice4halt
    _pb 'rc.local'
    sudo cp "$FOL_DDT"/_dt_files/rc.local /etc/rc.local
    sudo chmod +x /etc/rc.local
    sudo systemctl enable rc-local
    sudo systemctl status rc-local
    _e $? "rc.local"
}
