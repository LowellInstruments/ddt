#!/usr/bin/env bash

source dt_utils.sh
VF=$HOME/.vpn
NAME=.this_peer
grep Raspberry /proc/cpuinfo
is_rpi=$?


function install_vpn {

    _pb "generating keys for this local peer"
    mkdir "$VF" 2> /dev/null
    wg genkey > "$VF"/$NAME.key
    wg pubkey < "$VF"/$NAME.key > "$VF"/$NAME.pub
    _py "we will solve any umask warning later"



    _pb "creating this peer's /etc/wireguard/wg0.conf"
    if [ $is_rpi -eq 0 ]; then
        _f=/etc/wireguard/wg0.conf
        (sudo echo -e "\n# file auto-created by Lowell Instruments tool"; \
        sudo echo -e  "#----------------------------------------------"; \
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


    _py "# -----------------------------------------------------------"
    _py "# copy-paste this to Hub's /etc/wireguard/wg0.conf so it     "
    _py "# knows about this remote peer, then restart hub's wireguard "
    _py "#     $ sudo systemctl restart wg-quick@wg0.service          "
    _py "# -----------------------------------------------------------"
    printf "\t[Peer]\n"
    printf "\tPublicKey = %s\n" "$(cat "$VF"/$NAME.pub)"
    printf "\tAllowedIPs = %s/32\n" "$2"
    printf "\n"



    if [ $is_rpi -eq 0 ]; then
        _S='solving umask warning'
        _pb "$_S"
        sudo chmod 600 "$VF"/$NAME.key && \
        sudo chmod 600 "$VF"/$NAME.pub && \
        sudo chmod 600 /etc/wireguard/wg0.conf && \
        sudo chown root /etc/wireguard/wg0.conf && \
        sudo chgrp root /etc/wireguard/wg0.conf
        _e $? "$_S"
    fi


    if [ $is_rpi -eq 0 ]; then
        _pb "restarting wireguard service"
        sudo systemctl enable wg-quick@wg0.service
        sudo systemctl restart wg-quick@wg0.service
        _pb "ensure wireguard service active"
        sudo systemctl is-active wg-quick@wg0.service
    fi
}



# this script has a slightly different structure
clear && echo
_pb "running dt_install_vpn.sh"


# step 1) remove any previous result files
rm "$VF"/$NAME.vpn_pub_hub 2> /dev/null
rm "$VF"/$NAME.vpn_ip 2> /dev/null


# step 2) call python script to get VPN IP address and hub VPN public key
# password must be previously stored in file $HOME/.api_pw
api_pw=$(cat "$HOME"/.api_pw)
python3 _dt_files/ddn_cli_api_vpn.py "$api_pw"


# step 3) use python results to call bash function "install_vpn" in this file
if [ ! -f "$VF"/$NAME.vpn_pub_hub ]; then _e 1 "fail vpn_pub_hub"; exit 1; fi
if [ ! -f "$VF"/$NAME.vpn_ip ]; then _e 1 "fail vpn_ip_for_me"; exit 1; fi
vhp=$(cat "$VF"/$NAME.vpn_pub_hub)
vim=$(cat "$VF"/$NAME.vpn_ip)
if [ "$vhp" == "vpn_pub_empty" ]; then _e 1 "fail empty vpn_pub_hub"; exit 1; fi
install_vpn "$vhp" "$vim"
