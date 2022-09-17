#!/usr/bin/env bash
LI=/home/pi/li
DDT=$LI/ddt


# abort upon any error
clear && echo && set -e
trap 'echo ‘$BASH_COMMAND’ TRAPPED! rv $?' EXIT


printf '\n\n\n---- Install SW-NET service ----\n'


printf 'I > permissions ifmetric \n'
sudo setcap 'cap_net_raw,cap_net_admin+eip' /usr/sbin/ifmetric

printf 'I > LI DDS switch_net service \n'
sudo systemctl stop unit_dds_switch_net.service || true
sudo cp $DDT/_dt_files/unit_dds_switch_net.service /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/unit_dds_switch_net.service
sudo systemctl daemon-reload
sudo systemctl disable unit_dds_switch_net.service
sudo systemctl enable unit_dds_switch_net.service
sudo systemctl start unit_dds_switch_net.service

# get rid of any other version
sudo systemctl disable unit_switch_net.service || true


echo 'I > SW-NET service OK'
echo 'I > check w/ sudo systemctl status unit_dds_switch_net.service'
