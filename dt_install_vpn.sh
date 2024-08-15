#!/usr/bin/env bash
source dt_utils.sh


function install_vpn {
    clear && echo && echo
    _pb "INSTALL VPN"


    echo
    _pb "creating wireguard keys"
    wg genkey > /tmp/pri && wg pubkey < /tmp/pri > /tmp/pub
    PRI=$(cat /tmp/pri)
    PUB=$(cat /tmp/pub)


    echo
    _pb "generating this NODE's wireguard configuration file..."
    _NODE="
    [Interface]
    # info about this node
    Address = $1/32
    PrivateKey = $PRI
        # info about the HUB
        [Peer]
        PublicKey = Z013dqulL/htKFs2Z4YTKG9BA9J4kGZ7IqHZovcMp1w=
        Endpoint = 3.143.21.254:51820
        # hosts allowed to reach this peer via HUB
        AllowedIPs = 10.5.0.0/24
        PersistentKeepalive = 25
    "
    echo "$_NODE" | sudo tee -a /etc/wireguard/wg0.conf > /dev/null



    echo
    _pb "please paste the following to Lightsail HUB wireguard configuration file"
    _HUB="
    [Peer]
    PublicKey = $PUB
    AllowedIPs = $1/32
    "
    echo "$_HUB"


    _pb "restart wireguard"
    sudo systemctl restart wg-quick@wg0.service && sudo systemctl enable wg-quick@wg0.service
}


# example call this script
# ./dt_install_vpn.sh 1.2.3.4
install_vpn "$1"

