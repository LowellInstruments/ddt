#!/usr/bin/bash


source /home/pi/li/ddh/scripts/utils.sh
clear
echo "usage: <name> branch_ddt branch_ddh"



# constants
if [ -z "$1" ]; then BRANCH_DDT=toml; else BRANCH_DDT=$1; fi
if [ -z "$2" ]; then BRANCH_DDH=toml; else BRANCH_DDH=$2; fi



echo
_S="[ DDU ] install DDT branch $BRANCH_DDT"
_pb "$_S"
cd "$FOL_DDT" && \
    (git checkout -fb "$BRANCH_DDT" || git checkout "$BRANCH_DDT") && \
    git fetch origin "$BRANCH_DDT":refs/remotes/origin/"$BRANCH_DDT" --depth 1 && \
    git reset --hard origin/"$BRANCH_DDT"
_e $? "$_S"



echo
_S="[ DDU ] install MAT"
_pb "$_S"
pip install --upgrade --no-deps --force-reinstall \
    mat@git+https://github.com/LowellInstruments/mat.git
_e $? "$_S"



echo
_S="[ DDU ] install DDH branch $BRANCH_DDH"
_pb "$_S"
cd "$FOL_DDH" && \
    (git checkout -fb "$BRANCH_DDH" || git checkout "$BRANCH_DDH") && \
    git fetch origin "$BRANCH_DDH":refs/remotes/origin/"$BRANCH_DDH" --depth 1 && \
    git reset --hard origin/"$BRANCH_DDH"
_e $? "$_S"



echo
_S="[ DDU ] install DDH extra requirements"
_pb "$_S"
source "$FOL_VEN"/bin/activate && \
pip3 install -r "$FOL_DDH"/requirements_extra.txt
_e $? "$_S"



echo
_S="[ DDU ] install DDH plugins"
_pb "$_S"
cp "$FOL_DDT"/_dt_files/ble_dl_moana.py "$FOL_DDH"/dds
_e $? "$_S"



echo
_S="[ DDU ] install climenu"
_pb "$_S"
gcc "$FOL_DDT"/_dt_files/climenu.c -o "$FOL_DDT"/_dt_files/cm
sudo killall cm 2> /dev/null
sudo cp "$FOL_DDT"/_dt_files/cm /usr/local/bin && \
sudo cp "$FOL_DDT"/_dt_files/cmi.conf /etc && \
sudo cp "$FOL_DDT"/_dt_files/cmu.conf /etc
_e $? "$_S"



echo
_S="[ DDU ] install aliases"
_pb "$_S"
cd "$FOL_DDT" && ./dt_install_alias.sh force
_e $? "$_S"
source /home/pi/.bashrc
_e $? "$_S"



echo
_S="[ DDU ] install services"
_pb "$_S"
sudo systemctl daemon-reload
# this is the service to switch cell <--> wi-fi
sudo systemctl restart unit_switch_net.service
sudo systemctl enable unit_switch_net.service
_e $? "$_S"




echo
_S="[ DDU ] kill DDH, DDS, API"
_pb "$_S"
killall main_dds_controller
killall main_ddh_controller
killall main_api_controller
killall main_dds
killall main_ddh
killall main_api



echo
_pg "[ DDU ] update OK!"
