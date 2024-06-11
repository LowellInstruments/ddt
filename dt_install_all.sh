#!/usr/bin/env bash


clear
echo


source dt_install_check.sh
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
source dt_install_display_calib.sh


if [ "$1" == "skip_ppp" ]; then
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
    # install_ppp && \
    install_service_sw_net && \
    install_fw_cell_shield
else
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
fi


#if [ detect bookworm not bullseye ]; then
#    install_display_calib
#fi


echo "------------------------------------------------"
echo "dt_install_all.sh done"
echo "now complete your ddh/settings/config.toml file"
echo "or request one to your DDH service provider"
echo "------------------------------------------------"


# so we don't try to run DDH / DDS right after install
# because it will fail because cell stuff needs a reboot
touch "$LI_DDH_NEEDS_REBOOT_POST_INSTALL"

