#!/usr/bin/env bash


FI=/home/pi/li
VENV=$FI/venv
VPIP=$VENV/bin/pip
FH=/home/pi/li/ddh
FS=/home/pi/li/dds
TH=/tmp/git_ddh
TS=/tmp/git_dds
FB=/tmp/dds_backup


# abort upon any error
echo && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


printf '\n\n\n---- Install / Update DDH and DDS ----\n'


# backup existing DDH configuration
printf 'U > backup\n'
rm -rf $FB || true
mkdir -p $FB
if [ -d $FS/dl_files ]; then cp -r $FS/dl_files $FB; fi
if [ -t $FS/dds_run.sh ]; then cp $FS/dds_run.sh $FB; fi
if [ -t $FS/settings/ddh.json ]; then cp $FS/settings/ddh.json $FB; fi
cp $FS/settings/_macs_to_sn.yml $FB || true


# try to pull DDH & DDS from git
printf 'U > uninstall\n'
rm -rf /tmp/git* || true


printf 'U > clone from github\n'
git clone -b v4 https://github.com/lowellinstruments/ddh.git "$TH"
$VPIP install -r $FH/requirements.txt
git clone https://github.com/lowellinstruments/dds.git "$TS"
$VPIP install -r $FS/requirements.txt


# restore configuration we backed up before
printf 'U > restore backup\n'
cp -r $FB/dl_files $TS
cp $FB/dds_run.sh "$TS"/dds_run.sh
cp $FB/ddh.json "$TS"/settings
cp $FB/_macs_to_sn.yml "$TS"/settings 2> /dev/null || true


# we reached here, we are doing well
printf 'U > install\n'
rm -rf $FH
rm -rf $FS
mv $TH $FH
mv $TS $FS


printf 'I > ensuring resolv.conf \n'
sudo chattr -i /etc/resolv.conf
sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
sudo sh -c "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf"
sudo chattr +i /etc/resolv.conf


echo; echo 'U > DDH and DDS finished'
