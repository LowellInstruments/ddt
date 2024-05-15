#!/usr/bin/bash


source /home/pi/li/ddh/scripts/utils.sh
clear


# constants
FTS=/tmp/ddh_stash


_S="[ POP ] ddh | updating DDT"
_pb "$_S"
cd "$FOL_DDT" && \
git reset --hard && \
git pull
_e $? "$_S"


_S="[ POP ] ddh | stashing configuration files"
_pb "$_S"
rm -rf $FTS
mkdir $FTS && \
# TOML files: config.toml, all_macs.toml, rerun_flag.toml
cp "$FOL_DDH"/settings/*.toml $FTS && \
cp "$FOL_DDH"/scripts/script_logger_dox_deploy_cfg.json $FTS
_e $? "$_S"
# might be there or not
cp "$FOL_DDH"/ddh/db/db_his.json $FTS



_S="[ POP ] ddh | getting last github DDH code"
_pb "$_S"
cd "$FOL_DDH" && \
git reset --hard && \
git pull
_e $? "$_S"



_S="[ POP ] ddh | pip installing extra requirements"
_pb "$_S"
source "$FOL_VEN"/bin/activate && \
pip3 install -r "$FOL_DDH"/requirements_extra.txt
_e $? "$_S"




_S="[ POP ] ddh | un-stashing configuration files"
_pb "$_S"
cp $FTS/*.toml "$FOL_DDH"/settings && \
cp $FTS/script_logger_dox_deploy_cfg.json "$FOL_DDH"/scripts
_e $? "$_S"
# might be there or not
cp $FTS/db_his.json "$FOL_DDH"/ddh/db



_S="[ POP ] ddh | updating DDT and installing Moana plugin from it"
_pb "$_S"
cp "$FOL_DDT"/_dt_files/ble_dl_moana.py "$FOL_DDH"/dds
_e $? "$_S"



_S="[ POP ] ddh | renaming pyca scripts"
_pb "$_S"
if [ $(arch) = "armv7l" ]; then
    cp "$FOL_DDH/scripts/main_brt_armv7l.pyca" "$FOL_DDH/scripts/main_brt.pyc"
fi
if [ $(arch) = "aarch64" ]; then
    cp "$FOL_DDH/scripts/main_brt_aarch64.pyca" "$FOL_DDH/scripts/main_brt.pyc"
fi


_S="[ POP ] ddh | killing API ddh, should restart automatically"
_pb "$_S"
killall main_api


_pg "[ POP ] ddh | done OK!"
