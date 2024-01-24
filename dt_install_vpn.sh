#!/usr/bin/env bash


VF=$HOME/.vpn
NAME=.this_peer


grep Raspberry /proc/cpuinfo
is_rpi=$?


function install_vpn {
    source dt_utils.sh
    _pb "INSTALL DDH VPN"
    printf "install_vpn <pubkey_of_hub> <ip_of_this_peer>\n"


    if [ $is_rpi -eq 0 ]; then
        _pb "installing wireguard if needed"
        sudo apt install wireguard
    fi


    _pb "generating keys for this peer"
    mkdir "$VF" 2> /dev/null
    wg genkey > "$VF"/$NAME.key
    wg pubkey < "$VF"/$NAME.key > "$VF"/$NAME.pub


    printf "\n"
    _pb "taking care of umask warning..."
    if [ $is_rpi -eq 0 ]; then
      sudo chmod 600 "$VF"/$NAME.key
      sudo chmod 600 "$VF"/$NAME.pub
    fi


    printf "\n"
    _pb "# ----------------------------------------------\n"
    _pb "# creating this peer's /etc/wireguard/wg0.conf\n"
    _pb "# ----------------------------------------------\n"
    printf "\n"
    if [ $is_rpi -eq 0 ]; then
        _f=/etc/wireguard/wg0.conf
        sudo echo -e "# file auto-created by Lowell Instruments tool" | sudo tee $_f > /dev/null
        sudo echo -e  "----------------------------------------------" | sudo tee $_f > /dev/null
        sudo echo -e  "# info about myself as a peer" | sudo tee $_f > /dev/null
        sudo echo -e  "[Interface]" | sudo tee $_f > /dev/null
        sudo printf   "Address = %s/32\n" "$2" | sudo tee $_f > /dev/null
        sudo printf   "PrivateKey = %s \n\n" "$(cat "$VF"/$NAME.key)" | sudo tee $_f > /dev/null
        sudo echo -e  "\t# info about the Hub" | sudo tee $_f > /dev/null
        sudo echo -e  "\t[Peer]" | sudo tee $_f > /dev/null
        sudo printf   "\tPublicKey = %s\n" "$1" | sudo tee $_f > /dev/null
        sudo echo -e  "\tEndpoint = 3.143.21.254:51820" | sudo tee $_f > /dev/null
        sudo echo -e  "\t# set hosts allowed to reach this peer via HUB" | sudo tee $_f > /dev/null
        sudo echo -e  "\tAllowedIPs = 10.5.0.0/24" | sudo tee $_f > /dev/null
        sudo echo -e  "\tPersistentKeepalive = 25" | sudo tee $_f > /dev/null
    fi
    printf "\n\n\n"
    _pb "# ----------------------------------------------\n"
    _pb "# paste to the Hub's /etc/wireguard/wg0.conf\n"
    _pb "# ----------------------------------------------\n"
    printf "\n"
    printf "# info about the remote peer\n"
    printf "\t[Peer]\n"
    printf "\tPublicKey = %s\n" "$(cat "$VF"/$NAME.pub)"
    printf "\tAllowedIPs = %s/32\n" "$2" >> pepi.txt


    # permissions
    if [ $is_rpi -eq 0 ]; then
      sudo chmod 600 /etc/wireguard/wg0.conf
      sudo chown root /etc/wireguard/wg0.conf
      sudo chgrp root /etc/wireguard/wg0.conf
    fi
}


install_vpn "<pubkey_of_hub>" 10.5.0.69
