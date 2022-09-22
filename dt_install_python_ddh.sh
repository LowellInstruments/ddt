#!/usr/bin/env bash


FI=/home/pi/li
VENV="$FI"/venv
VPIP="$VENV"/bin/pip3
FH=/home/pi/li/ddh
FS="$FH"/dds
TH=/tmp/ddh


# abort upon any error
echo && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


printf '\n\n\n---- Install / Update DDH ----\n'


# clone DDH from git -> /tmp
printf 'I > clone from github\n'
rm -rf "$TH" || true
git clone https://github.com/lowellinstruments/ddh_v4.git "$TH"



# backup existing DDH configuration -> /tmp
printf 'I > backup\n'
if [ -d "$FH"/dl_files ]; then cp -r "$FH"/dl_files "$TH"; fi
if [ -t "$FS"/dds_run.sh ]; then cp "$FS"/dds_run.sh "$TH"/dds; fi
if [ -t "$FH"/settings/ddh.json ]; then cp "$FH"/settings/ddh.json "$TH"/settings; fi
cp "$FH"/settings/_macs_to_sn.yml "$TH"/settings || true



# we reached here, we are doing well
printf 'I > install\n'
rm -rf $FH
mv $TH $FH
$VPIP install -r $FH/requirements.txt


printf 'I > ensuring resolv.conf \n'
sudo chattr -i /etc/resolv.conf
sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
sudo sh -c "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf"
sudo chattr +i /etc/resolv.conf


echo; echo 'I > DDH finished'
