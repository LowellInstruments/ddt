#!/usr/bin/env bash

FOL_LI=/home/pi/li
FOL_DDH=$FOL_LI/ddh


clear
echo "BACKUP DDH YELLOW VERSION"
cd "$FOL_LI" || (echo "error: bad working directory"; exit 1)


echo "detecting old yellow boat DDH version"
[ -f $FOL_DDH/settings/ddh.json ]
rv=$?
if [ $rv -eq 0 ]; then
    echo "creating old yellow boat DDH folder backup to ddh_yellow"
    mv "$FOL_DDH" "$FOL_LI"/ddh_yellow
fi


echo "killing any currently running DDH software"
killall main_ddh_controller
killall main_ddh
killall main_dds_controller
killall main_dds


echo "cloning latest DDT"
rm -rf /home/pi/li/ddt
git clone https://github.com/lowellinstruments/ddt.git -b toml


echo "backup_yellow done, proceed to run ./dt_install_all.sh"
