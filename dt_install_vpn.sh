#!/usr/bin/env bash



VF=$HOME/.vpn
NAME=.this_peer
MAC_ADDR=$(cat /sys/class/net/eth0/address)
grep Raspberry /proc/cpuinfo
is_rpi=$?


# this script:
#   1) gets own DDH eth0 MAC address (ma)
#   2) uses (ma) to curl-query DDN API to get:
#       - a VPN IP address (va) for this DDH
#       - the HUB VPN public key
#   3) use info from 2) to generate own wireguard configuration


function install_vpn {
    source dt_utils.sh
    _pb "INSTALL DDH VPN KEYS"
    printf "install_vpn <pubkey_of_hub> <ip_of_this_peer>\n"


    if [ $is_rpi -eq 0 ]; then
        _pb "installing wireguard if needed"
        sudo apt install wireguard
    fi


    _pb "\ngenerating keys for this peer"
    mkdir "$VF" 2> /dev/null
    wg genkey > "$VF"/$NAME.key
    wg pubkey < "$VF"/$NAME.key > "$VF"/$NAME.pub


    _pb "creating this peer's /etc/wireguard/wg0.conf"
    if [ $is_rpi -eq 0 ]; then
        _f=/etc/wireguard/wg0.conf
        (sudo echo -e "\n# file auto-created by Lowell Instruments tool"; \
        sudo echo -e  "----------------------------------------------"; \
        sudo echo -e  "# info about myself as a peer"; \
        sudo echo -e  "[Interface]"; \
        sudo printf   "Address = %s/32\n" "$2"; \
        sudo printf   "PrivateKey = %s \n\n" "$(cat "$VF"/$NAME.key)"; \
        sudo echo -e  "\t# info about the Hub"; \
        sudo echo -e  "\t[Peer]"; \
        sudo printf   "\tPublicKey = %s\n" "$1"; \
        sudo echo -e  "\tEndpoint = 3.143.21.254:51820"; \
        sudo echo -e  "\t# set hosts allowed to reach this peer via HUB"; \
        sudo echo -e  "\tAllowedIPs = 10.5.0.0/24"; \
        sudo echo -e  "\tPersistentKeepalive = 25\n";) | sudo tee $_f > /dev/null
    fi
    printf "\n"


    _pb "# --------------------------------------------------"
    _pb "# copy-paste this to Hub's /etc/wireguard/wg0.conf"
    _pb "# --------------------------------------------------"
    printf "\n"
    printf "# info about the remote peer\n"
    printf "\t[Peer]\n"
    printf "\tPublicKey = %s\n" "$(cat "$VF"/$NAME.pub)"
    printf "\tAllowedIPs = %s/32\n" "$2"
    printf "\n"



    _pb "taking care of umask warning..."
    if [ $is_rpi -eq 0 ]; then
        sudo chmod 600 "$VF"/$NAME.key
        sudo chmod 600 "$VF"/$NAME.pub
        sudo chmod 600 /etc/wireguard/wg0.conf
        sudo chown root /etc/wireguard/wg0.conf
        sudo chgrp root /etc/wireguard/wg0.conf
    fi
}


install_vpn "<pubkey_of_hub>" 10.5.0.69
