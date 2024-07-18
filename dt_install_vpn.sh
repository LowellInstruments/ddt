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


    _pb "paste this to NODE wireguard configuration file"
    echo
    echo "[Interface]"
    echo "# info about this node"
    echo "Address = $1/32"
    echo "PrivateKey = $PRI"
    echo "    # info about the HUB"
    echo "    [Peer]"
    echo "    PublicKey = Z013dqulL/htKFs2Z4YTKG9BA9J4kGZ7IqHZovcMp1w="
    echo "    Endpoint = 3.143.21.254:51820"
    echo "    # hosts allowed to reach this peer via HUB"
    echo "    AllowedIPs = 10.5.0.0/24"
    echo "    PersistentKeepalive = 25"
    echo


    _pb "paste this to HUB wireguard configuration file"
    echo
    echo "[Peer]"
    echo "PublicKey=$PUB"
    echo "AllowedIPs = $1/32"
    echo


    _pb "restart wireguard"
    sudo systemctl restart wg-quick@wg0.service && sudo systemctl enable wg-quick@wg0.service
}


#install_vpn $1
install_vpn 1.2.3.4