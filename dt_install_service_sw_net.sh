#!/usr/bin/env bash
source dt_utils.sh


function install_service_sw_net {
    title dt_install_service_sw_net


    _pb "INSTALL SERVICE_SW_NET"
    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    _pb "ifmetric"
    sudo setcap 'cap_net_raw,cap_net_admin+eip' /usr/sbin/ifmetric
    _e $? "ifmetric"


    # LI switch_net_service only on pure DDH
    _pb "switch_net_service"

    # install the service
    (sudo systemctl stop unit_switch_net.service || true) && \
    sudo cp "$FOL_DDT"/_dt_files/unit_switch_net.service /etc/systemd/system/ && \
    sudo chmod 644 /etc/systemd/system/unit_switch_net.service && \
    sudo systemctl daemon-reload && \
    (sudo systemctl disable unit_switch_net.service || true) && \
    sudo systemctl enable unit_switch_net.service && \
    sudo systemctl start unit_switch_net.service
    _e $? "starting switch net service"


    _pb "is switch_net_service active"
    systemctl is-active unit_switch_net.service | grep -w active
    _e $? "switch_net_service NOT active"

}

if [ "$1" == "force" ]; then install_service_sw_net; fi
