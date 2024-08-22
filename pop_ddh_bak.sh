#!/usr/bin/bash


source /home/pi/li/ddh/scripts/utils.sh
clear


# constants
FTS=/tmp/ddh_stash


echo
_S="[ POP ] updating DDT"
_pb "$_S"
cd "$FOL_DDT" && \
git reset --hard && \
git pull
_e $? "$_S"



echo
_S="[ POP ] stashing DDH configuration files"
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
_S="[ POP ] updating DDH"
_pb "$_S"
cd "$FOL_DDH" && \
git reset --hard && \
git pull
_e $? "$_S"



echo
_S="[ POP ] updating DDH requirements"
_pb "$_S"
source "$FOL_VEN"/bin/activate && \
pip3 install -r "$FOL_DDH"/requirements_extra.txt
_e $? "$_S"




echo
_S="[ POP ] un-stashing DDH configuration files"
_pb "$_S"
cp $FTS/*.toml "$FOL_DDH"/settings && \
cp $FTS/script_logger_dox_deploy_cfg.json "$FOL_DDH"/scripts
_e $? "$_S"
# might be there or not
cp $FTS/db_his.json "$FOL_DDH"/ddh/db



echo
_S="[ POP ] installing Moana plugin from DDT"
_pb "$_S"
cp "$FOL_DDT"/_dt_files/ble_dl_moana.py "$FOL_DDH"/dds
_e $? "$_S"


echo
_S="[ POP ] kill API, it will auto-restart"
_pb "$_S"
killall main_api



echo
_S="[ POP ] kill DDH, it will auto-restart"
_pb "$_S"
killall main_dds_controller
killall main_ddh_controller
killall main_dds
killall main_ddh



echo
_pg "[ POP ] all OK!"
echo
