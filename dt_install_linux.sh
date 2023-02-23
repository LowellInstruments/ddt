#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt
J4H="$F_LI"/juice4halt
EMOLT_FILE_FLAG=/home/pi/li/.ddt_this_is_emolt_box.flag


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT
if [ "$PWD" != "$F_DT" ]; then echo 'wrong starting folder'; exit 1; fi


printf '\n\n\n---- dt_install_linux ----\n'


printf '\n\n>>> preventing bluez from ever upgrading\n'
sudo apt-mark hold bluez


printf '\n\n>>> running linux apt-get\n'
sudo apt-get update
sudo apt remove python3-numpy
sudo apt-get --yes --force-yes install xscreensaver matchbox-keyboard ifmetric joe git \
libatlas3-base libglib2.0-dev python3-pyqt5 libhdf5-dev python3-dev \
libgdal-dev libproj-dev proj-data proj-bin python3-gdbm python3-venv \
libcurl4-gnutls-dev gnutls-dev python3-pycurl libdbus-1-dev \
libudev-dev libical-dev libreadline-dev libcap-dev awscli


# install stuff only on pure Lowell Instruments DDH such as wiringpi and juice4halt
if ! test -f $EMOLT_FILE_FLAG; then
    # already done by ppp_install_standalone.sh
    # printf '\n\n>>> installing wiringpi\n'
    # sudo dpkg -i ./_dt_files/wiringpi-latest.deb
    printf '\n\n>>> installing juice4halt\n'
    sudo rm -rf "$J4H"
    mkdir -p "$J4H"/bin
    cp "$F_DT"/_dt_files/shutdown_script.py "$J4H"/bin/
else
    printf '\n\n>>> not installing juice4halt, this is emolt box\n'
fi


printf '\n\ncleaning up...\n'
sudo apt autoremove -y
sudo apt-get clean


printf '\n\n>>> installing rc.local\n'
sudo cp "$F_DT"/_dt_files/rc.local /etc/rc.local
sudo chmod +x /etc/rc.local
sudo systemctl enable rc-local
sudo systemctl status rc-local


printf '\n\n>>> dt_install_linux = OK\n'
