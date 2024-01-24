#!/usr/bin/env bash


VF=$HOME/.vpn/


function install_vpn {
    source dt_utils.sh
    _pb "INSTALL DDH VPN, run this as:"
    _pb "install_vpn <pubkey_of_hub> <ip_of_this_peer>"

#    sudo apt install wireguard
#    mkdir "$VF" 2> /dev/null
#    cd "$VF" && umask 077
#    _e $? "vpn folder"
#
#
#    # ep: endpoint
#    _pb "generating keys"
#    wg genkey > "$VF"/.ep.key
#    wg pubkey < "$VF"/.ep.key > "$VF"/.ep.pub
#

    printf "# ----------------------------------------------\n"
    printf "# paste to this peer's /etc/wireguard/wg0.conf\n"
    printf "# ----------------------------------------------\n"
    printf "\n"
    printf "# info about myself as a peer\n"
    printf "[Interface]\n"
    printf "Address = %s/32\n" "$2"
    printf "PrivateKey = %s \n" "$(cat "$VF"/.ep.key)"
    printf "\n"
    printf "\t# info about the Hub\n"
    printf "\t[Peer]\n"
    printf "\tPublicKey = %s\n" "$1"
    printf "\tEndpoint = 3.143.21.254:51820\n"
    printf "\t# set hosts allowed to reach this peer via HUB\n"
    printf "\tAllowedIPs = 10.5.0.0/24\n"
    printf "\tPersistentKeepalive = 25\n"
    printf "\n"
    printf "\n"
    printf "# ----------------------------------------------\n"
    printf "# paste to the Hub's /etc/wireguard/wg0.conf\n"
    printf "# ----------------------------------------------\n"
    printf "\n"
    printf "\t[Peer]\n"
    printf "\tPublicKey = %s\n" "$(cat "$VF"/.ep.pub)"
    printf "\tAllowedIPs = %s/32\n" "$2"


    # permissions
    grep Raspberry /proc/cpuinfo
    rv=$?
    if [ $rv -eq 0 ]; then
      sudo chmod 600 /etc/wireguard/wg0.conf
      sudo chown root /etc/wireguard/wg0.conf
      sudo chgrp root /etc/wireguard/wg0.conf
    fi
}


install_vpn "<pubkey_of_hub>" 10.5.0.69
