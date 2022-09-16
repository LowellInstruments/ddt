#!/usr/bin/env bash


# abort upon any error
echo && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


printf '\n\n\n---- Update DDH and DDS ----\n'


# backup existing DDH configuration
# FS: folder dds / FB: backup
printf 'U > backup\n'
FS=/home/pi/li/dds
FB=/tmp/dds_backup
rm -rf $FB || true
mkdir -p $FB
cp -r $FS/dl_files $FB
cp $FS/dds_run.sh $FB           # this has the AWS keys
cp $FS/settings/ddh.json $FB    # this has the DDH MACS to monitor
cp $FS/settings/_macs_to_sn.yml $FB || true


# try to pull DDH & DDS from git
# TH: temporary folder ddh github / TS: dds
printf 'U > uninstall\n'
rm -rf /tmp/git* || true
TH=/tmp/git_ddh
TS=/tmp/git_dds



printf 'U > clone from github\n'
git clone -b v4 https://github.com/lowellinstruments/ddh.git "$TH"
git clone https://github.com/lowellinstruments/dds.git "$TS"


# restore configuration we backed up before
printf 'U > restore backup\n'
cp -r $FB/dl_files $TS
cp $FB/dds_run.sh "$TS"/dds_run.sh
cp $FB/ddh.json "$TS"/settings
cp $FB/_macs_to_sn.yml "$TS"/settings 2> /dev/null || true


# we reached here, we are doing well
printf 'U > install\n'
FH=/home/pi/li/ddh
rm -rf $FH
rm -rf $FS
mv $TH $FH
mv $TS $FS


echo; echo 'U > DDH and DDS finished'
