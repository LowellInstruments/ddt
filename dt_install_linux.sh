#!/usr/bin/env bash


# grab variables from file
. ./_dt_files/dt_variables.sh || (echo 'dt_vars fail'; exit 1)
J4H="$F_LI"/juice4halt


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT
if [ "$PWD" != "$F_DT" ]; then echo 'wrong starting folder'; exit 1; fi


printf '\n\n\n---- Install Linux ----\n'


printf 'I > apt-get\n'
sudo apt-get update
sudo apt-get -y install xscreensaver matchbox-keyboard ifmetric joe git \
libatlas3-base libglib2.0-dev python3-pyqt5 libhdf5-dev python3-dev \
libgdal-dev libproj-dev proj-data proj-bin python3-gdbm python3-venv \
libcurl4-gnutls-dev gnutls-dev python3-pycurl libdbus-1-dev \
libudev-dev libical-dev libreadline-dev



printf 'I > juice4halt\n'
rm -rf "$J4H"
mkdir -p "$J4H"/bin
cp "$F_DT"/_dt_files/shutdown_script.py "$J4H"/bin/


printf 'I > rc.local\n'
sudo cp "$F_DT"/_dt_files/rc.local /etc/rc.local
sudo chmod +x /etc/rc.local
sudo systemctl enable rc-local
sudo systemctl status rc-local


printf 'I > linux OK!\n'
