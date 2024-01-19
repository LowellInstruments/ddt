#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt
J4H="$F_LI"/juice4halt
EMOLT_FILE_FLAG=/home/pi/li/.ddt_this_is_emolt_box.flag


function install_linux {
    source dt_utils.sh
    _pb "INSTALL LINUX DEPENDENCIES"

    _pb "apt-get"
    sudo apt-mark hold bluez
    sudo apt remove -y modemmanager
    sudo apt-get --yes update
    sudo apt remove -y python3-numpy
    sudo apt-get --yes --force-yes install minicom xscreensaver matchbox-keyboard ifmetric joe git \
    libatlas3-base libglib2.0-dev python3-pyqt5 libhdf5-dev python3-dev \
    libgdal-dev libproj-dev proj-data proj-bin python3-gdbm python3-venv \
    libcurl4-gnutls-dev gnutls-dev python3-pycurl libdbus-1-dev \
    libudev-dev libical-dev libreadline-dev libcap-dev awscli python3-requests ninja-build
    _e $? "apt-get"


    # install stuff only on pure LI DDH such as wiringpi and juice4halt
    if ! test -f $EMOLT_FILE_FLAG; then
        _pb "juice4halt"
        # already done by ppp_install_standalone.sh
        # printf '\n\n>>> installing wiringpi\n'
        # sudo dpkg -i ./_dt_files/wiringpi-latest.deb
        sudo rm -rf "$J4H"
        mkdir -p "$J4H"/bin
        cp "$F_DT"/_dt_files/shutdown_script.py "$J4H"/bin/
        _e $? "juice4halt"
    fi


    _pb 'apt-get clean'
    sudo apt autoremove -y
    sudo apt-get clean


    _pb 'rc.local'
    sudo cp "$F_DT"/_dt_files/rc.local /etc/rc.local
    sudo chmod +x /etc/rc.local
    sudo systemctl enable rc-local
    sudo systemctl status rc-local
    _e $? "rc.local"
}
