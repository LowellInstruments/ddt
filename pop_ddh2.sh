#!/usr/bin/bash


source /home/pi/li/ddh/scripts/utils.sh
clear



# constants
FTS=/tmp/ddh_stash
F_CLONE_MAT=/tmp/mat



echo
_S="[ POP ] updating DDT"
_pb "$_S"
cd "$FOL_DDT" && \
git reset --hard && \
git pull
_e $? "$_S"



echo
_S="[ POP ] uninstall previous MAT library"
_pb "$_S"
"$FOL_VEN"/bin/pip3 uninstall -y mat
_e $? "$_S"



echo
_S="[ POP ] download new MAT library"
_pb "$_S"
rm -rf $F_CLONE_MAT
git clone https://github.com/lowellinstruments/mat.git $F_CLONE_MAT
_e $? "$_S"



echo
_S="[ POP ] patch MAT library"
_pb "$_S"
cp $F_CLONE_MAT/tools/_setup_wo_reqs.py $F_CLONE_MAT/setup.py
_e $? "$_S"



echo
_S="[ POP ] install new MAT library"
_pb "$_S"
"$FOL_VEN"/bin/pip3 install $F_CLONE_MAT
_e $? "$_S"



echo
_S="[ POP ] create MAT library local commit file"
_pb "$_S"
COM_MAT_LOC=$(cd "$F_CLONE_MAT" && git rev-parse master)
_e $? "cannot get MAT local commit file"
[ ${#COM_MAT_LOC} -eq 40 ]
_e $? "bad MAT $COM_MAT_LOC local commit file"
sudo echo "$COM_MAT_LOC" | sudo tee /etc/com_mat_loc.txt > /dev/null
_e $? "cannot copy MAT commit file to /etc/"




echo
_S="[ POP ] backup current DDH configuration files"
_pb "$_S"
rm -rf $FTS
mkdir $FTS && \
# TOML files: config.toml, all_macs.toml, rerun_flag.toml
cp "$FOL_DDH"/settings/*.toml $FTS && \
cp "$FOL_DDH"/scripts/script_logger_dox_deploy_cfg.json $FTS
_e $? "$_S"
# might be there or not
cp "$FOL_DDH"/ddh/db/db_his.json $FTS



echo
_S="[ POP ] update DDH"
_pb "$_S"
cd "$FOL_DDH" && \
git reset --hard && \
git pull
_e $? "$_S"



echo
_S="[ POP ] install DDH extra requirements"
_pb "$_S"
source "$FOL_VEN"/bin/activate && \
pip3 install -r "$FOL_DDH"/requirements_extra.txt
_e $? "$_S"



echo
_S="[ POP ] un-stash DDH configuration files"
_pb "$_S"
cp $FTS/*.toml "$FOL_DDH"/settings && \
cp $FTS/script_logger_dox_deploy_cfg.json "$FOL_DDH"/scripts
_e $? "$_S"
# might be there or not
cp $FTS/db_his.json "$FOL_DDH"/ddh/db



echo
_S="[ POP ] install Moana plugin from DDT"
_pb "$_S"
cp "$FOL_DDT"/_dt_files/ble_dl_moana.py "$FOL_DDH"/dds
_e $? "$_S"



echo
_S="[ POP ] kill API, it will auto-start"
_pb "$_S"
killall main_api




echo
_S="[ POP ] kill DDH, it will auto-start"
_pb "$_S"
killall main_dds_controller
killall main_ddh_controller
killall main_dds
killall main_ddh



echo
_S="[ POP ] compile binary climenu"
_pb "$_S"
gcc "$FOL_DDT"/_dt_files/climenu.c -o "$FOL_DDT"/_dt_files/cm
_e $? "$_S"



echo
_S="[ POP ] install binary climenu"
_pb "$_S"
sudo killall cm 2> /dev/null
sudo cp "$FOL_DDT"/_dt_files/cm /usr/local/bin && \
sudo cp "$FOL_DDT"/_dt_files/cmi.conf /etc && \
sudo cp "$FOL_DDT"/_dt_files/cmu.conf /etc
_e $? "$_S"



echo
_pg "[ POP ] all OK!"
