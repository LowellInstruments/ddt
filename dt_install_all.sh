#!/usr/bin/env bash


clear
echo


source dt_install_custom_box.sh
source dt_install_linux.sh
source dt_install_linux_bluez.sh
source dt_install_ddh.sh
# see this line section below, installs ppp
source dt_install_service_sw_net.sh
source dt_install_alias.sh
source dt_install_icons.sh
source dt_install_crontab.sh


install_custom
install_linux
install_bluez
install_ddh
_dt_files/ppp_install_custom.sh
install_service_sw_net
install_alias
install_icons
install_crontab
