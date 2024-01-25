#!/usr/bin/env bash



VPN_ADDR=ip a s wg0 | grep -E -o \
'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2


# this script does the following:
#   1) obtain own DDH VPN interface IP address (va)
#   2) use (va) to query DDN API to get a DDH config.toml file
#       url = f'http://{API_IP}:{API_PORT}/{API_EP}/{va}'
# python _dt_files/ddn_cli.py "$1"
# note:
# configure DDN API so it only answers via its VPN interface


function install_config {
    source dt_utils.sh
    _pb "INSTALL DDH CONFIG"
}


install_config
