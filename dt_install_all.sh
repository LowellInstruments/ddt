#!/usr/bin/env bash


clear
echo


source dt_utils.sh
source dt_check.sh
#source dt_install_custom_box.sh
#source dt_install_linux.sh
#source dt_install_linux_bluez.sh
#source dt_install_ddh.sh
## see * below
#source dt_install_alias.sh
#source dt_install_icons.sh
#source dt_install_crontab.sh
#source dt_install_dws.sh
#source dt_install_service_sw_net.sh
#source dt_install_fw_cell_shield.sh


install_check
#install_custom && \
#install_linux && \
#install_bluez && \
#install_ddh && \
#install_alias && \
#install_icons && \
#install_crontab && \
#install_dws && \
## * ppp has no "source" instruction
#sudo _dt_files/ppp_install_custom.sh && \
#install_service_sw_net

# maybe yes maybe not
# install_fw_cell_shield
