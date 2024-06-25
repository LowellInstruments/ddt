#!/usr/bin/env bash
source dt_utils.sh



function install_linux {
    title dt_install_linux

    _pb "INSTALL LINUX DEPENDENCIES"
    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)

    _pb "apt-get"
    sudo apt-get --yes update
    sudo apt-mark hold bluez
    sudo apt remove -y modemmanager
    sudo apt remove -y python3-numpy
    sudo apt-get --yes --assume-yes install minicom xscreensaver matchbox-keyboard ifmetric joe git \
    libatlas3-base libglib2.0-dev python3-pyqt5 libhdf5-dev python3-dev \
    libgdal-dev libproj-dev proj-data proj-bin python3-gdbm python3-venv \
    libcurl4-gnutls-dev gnutls-dev python3-pycurl libdbus-1-dev libopenblas-dev \
    libudev-dev libical-dev libreadline-dev libcap-dev awscli python3-requests ninja-build wireguard \
    cmake xinput-calibrator x11-utils openssl shellinabox
    _e $? "apt-get"


    _pb 'apt-get clean'
    sudo apt autoremove -y
    sudo apt-get clean


    # install a Lowell Instruments DDH wallpaper
    export XAUTHORITY=/home/pi/.Xauthority
    export DISPLAY=:0
    pcmanfm --set-wallpaper "$FOL_DDT"/_dt_files/wp_ddh.jpg


    # rc.local runs display brightness, NTP, juice4halt, sailorhat
    _pb 'rc.local'
    sudo cp "$FOL_DDT"/_dt_files/rc.local /etc/rc.local && \
    sudo chmod +x /etc/rc.local && \
    sudo systemctl enable rc-local
    _e $? "starting rc.local"


    _pb "is rc.local active"
    sudo systemctl is-active rc-local
}

if [ "$1" == "force" ]; then install_linux; fi

