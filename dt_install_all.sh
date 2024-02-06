#!/usr/bin/env bash


clear
echo


source dt_check.sh
source dt_install_custom_box.sh
source dt_install_linux.sh
source dt_install_linux_bluez.sh
source dt_install_ddh.sh
source dt_install_api.sh
source dt_install_alias.sh
source dt_install_icons.sh
source dt_install_crontab.sh
source dt_install_dws.sh
source dt_install_ppp.sh
source dt_install_service_sw_net.sh
source dt_install_fw_cell_shield.sh


install_check && \
install_custom && \
install_linux && \
install_bluez && \
install_ddh && \
install_api && \
install_alias && \
install_icons && \
install_crontab && \
install_dws && \
install_ppp && \
install_service_sw_net && \
install_fw_cell_shield
