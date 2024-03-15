#!/usr/bin/bash


source /home/pi/li/ddh/scripts/utils.sh
clear


# constants
FTS=/tmp/ddh_stash


_S="[ POP ] ddh | stashing configuration files"
_pb "$_S"
rm -rf $FTS
mkdir $FTS && \
# TOML files: config.toml, all_macs.toml, rerun_flag.toml
cp "$FOL_DDH"/settings/*.toml $FTS && \
cp "$FOL_DDH"/scripts/script_logger_do_deploy_cfg.json $FTS
_e $? "$_S"
# might be there or not
# todo > test this
cp "$FOL_DDH"/ddh/db/db_his.json $FTS
_e $? "$_S"



_S="[ POP ] ddh | getting last github DDH code"
_pb "$_S"
cd "$FOL_DDH" && \
git reset --hard && \
git pull
_e $? "$_S"



_S="[ POP ] ddh | pip installing extra requirements"
_pb "$_S"
pip install -r "$FOL_DDH"/requirements_rpi_39_2023_extra.txt
_e $? "$_S"




_S="[ POP ] ddh | un-stashing configuration files"
_pb "$_S"
cp $FTS/*.toml "$FOL_DDH"/settings && \
cp $FTS/script_logger_do_deploy_cfg.json "$FOL_DDH"/scripts && \
cp $FTS/db_his.json "$FOL_DDH"/ddh/db
_e $? "$_S"



_S="[ POP ] ddh | updating DDT and installing Moana plugin from it"
_pb "$_S"
cd "$FOL_DDT" && \
git reset --hard && \
git pull && \
cp "$FOL_DDT"/_dt_files/ble_dl_moana.py "$FOL_DDH"/dds && \
_e $? "$_S"


_pg "[ POP ] ddh | done OK!"
