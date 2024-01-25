#!/usr/bin/env bash



VPN_ADDR="ip a s wg0 | grep -E -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2"


# this script does the following:
#   1) obtain own DDH VPN interface IP address (va)
#   2) use (va) to query DDN API to get a DDH config.toml file


function read_api_pw_to_file {
    source dt_utils.sh
    read -rp "enter api pw: " api_pw
    # shellcheck disable=SC2086
    echo "$api_pw" > "$HOME"/.api_pw
}


function install_config {
    source dt_utils.sh
    _pb "INSTALL DDH CONFIG"
}


read_api_pw_to_file
