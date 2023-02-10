#!/usr/bin/env bash


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT
if [ "$PWD" != "$F_DT" ]; then echo 'wrong starting folder'; exit 1; fi


printf '\n\n\n---- dt_install_bluez ----\n'


printf '\n\n>>> installing bluez linux dependencies'
sudo apt-get install -y libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev


printf '\n\n>>> downloading bluez 5.61\n'
wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.61.tar.xz
unxz bluez-5.61.tar.xz
tar xvf bluez-5.61.tar


printf '\n\n>>> installing bluez 5.61\n'
cd bluez-5.61 &&  \
./configure --prefix=/usr --mandir=/usr/share/man --sysconfdir=/etc --localstatedir=/var --enable-experimental && \
make -j4 && \
sudo make install


printf '\n\n>>> dt_install_bluez = OK, you should reboot now'
