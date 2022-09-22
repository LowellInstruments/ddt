#!/usr/bin/env bash


# grab variables from other script
. ./dt_variables.sh || (echo 'dt_vars fail'; exit 1)


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


printf '\n\n\n---- Install SW-NET service ----\n'


printf 'I > permissions ifmetric \n'
sudo setcap 'cap_net_raw,cap_net_admin+eip' /usr/sbin/ifmetric

printf 'I > LI switch_net service \n'
sudo systemctl stop unit_switch_net.service || true
sudo cp "$F_DT"/_dt_files/unit_switch_net.service /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/unit_switch_net.service
sudo systemctl daemon-reload
sudo systemctl disable unit_switch_net.service
sudo systemctl enable unit_switch_net.service
sudo systemctl start unit_switch_net.service


echo 'I > SW-NET service OK'
echo 'I > check w/ sudo systemctl status unit_switch_net.service'
