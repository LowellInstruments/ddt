#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT="$F_LI"/ddt


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


printf '\n\n\n---- Install SW-NET service ----\n'


printf '[ DDH ] ensuring permissions ifmetric \n\n'
sudo setcap 'cap_net_raw,cap_net_admin+eip' /usr/sbin/ifmetric

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
