#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt
EMOLT_FILE_FLAG=/home/pi/li/.ddt_this_is_emolt_box.flag


function install_service_sw_net {
    source dt_utils.sh
    _pb "INSTALL SERVICE_SW_NET"

    _pb "ifmetric"
    sudo setcap 'cap_net_raw,cap_net_admin+eip' /usr/sbin/ifmetric
    _e $? "ifmetric"

    # LI switch_net_service only on pure DDH
    _pb "switch_net_service"
    if ! test -f $EMOLT_FILE_FLAG; then return 0; fi
    read -rp "Is this emolt_DDH using CELL shield? (y/n) " choice
    case "$choice" in
        n|N ) printf 'not installing service_sw_net'; return 0;;
    esac

    (sudo systemctl stop unit_switch_net.service || true) && \
    sudo cp "$F_DT"/_dt_files/unit_switch_net.service /etc/systemd/system/ && \
    sudo chmod 644 /etc/systemd/system/unit_switch_net.service && \
    sudo systemctl daemon-reload && \
    (sudo systemctl disable unit_switch_net.service || true) && \
    sudo systemctl enable unit_switch_net.service && \
    sudo systemctl start unit_switch_net.service
    _e $? "switch net service"
    systemctl status unit_switch_net.service
}
