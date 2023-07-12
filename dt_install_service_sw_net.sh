#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt
EMOLT_FILE_FLAG=/home/pi/li/.ddt_this_is_emolt_box.flag


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


printf '\n\n\n---- Install SW-NET service ----\n'


printf '[ DDH ] ensuring permissions ifmetric \n\n'
sudo setcap 'cap_net_raw,cap_net_admin+eip' /usr/sbin/ifmetric


# LI switch_net_service only on pure DDH
if test -f $EMOLT_FILE_FLAG; then
    read -rp "Is this emolt_DDH box going to use a CELL connection / shield? (y/n) " choice
    case "$choice" in
        n|N ) printf 'not installing service_sw_net'; exit 0;;
    esac
fi



printf '[ DDH ] installing LI switch_net service \n\n'
sudo systemctl stop unit_switch_net.service || true
sudo cp "$F_DT"/_dt_files/unit_switch_net.service /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/unit_switch_net.service
sudo systemctl daemon-reload
sudo systemctl disable unit_switch_net.service
sudo systemctl enable unit_switch_net.service
sudo systemctl start unit_switch_net.service


echo '[ DDH ] checking status of the service right now'
systemctl status unit_switch_net.service
echo
