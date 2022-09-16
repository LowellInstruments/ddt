#!/usr/bin/env bash
LI=/home/pi/li
FOL_DDT=$LI/ddt
FOL_DDS=$LI/dds
FOL_DDH=$LI/ddh
FOL_DLF=$FOL_DDS/dl_files
VENV=$LI/venv
VPIP=$VENV/bin/pip
TSTAMP=/tmp/dl_files_$(date +%Y%M%d-%H%M%S)
DONE_BAK=0


# abort upon any error
clear && echo && set -e
trap 'echo ‘$BASH_COMMAND’ TRAPPED! rv $?' EXIT
if [ $PWD != $FOL_DDT ]; then echo 'wrong starting folder'; exit 1; fi


printf '\n\n\n---- Install Python base and DDH v4 ----\n'


printf 'I > backup current DDS dl_files to %s\n' "$TSTAMP"
if [ -d $FOL_DLF ]; then cp -r $FOL_DLF "$TSTAMP"; DONE_BAK=1; fi


printf 'I > uninstalling old DDH \n '
rm -rf $FOL_DDH || true


printf 'I > uninstalling old DDS \n '
rm -rf $FOL_DDS || true


# on RPi, venv needs to inherit PyQt5 installed via apt
printf 'I > virtualenv \n'
rm -rf $VENV || true
python3 -m venv $VENV --system-site-packages
source $VENV/bin/activate
$VPIP install --upgrade pip
$VPIP install wheel


printf 'I > clone DDH from github and install \n'
git clone https://github.com/LowellInstruments/ddh.git $FOL_DDH -b v4
$VPIP install -r $FOL_DDH/requirements.txt


printf 'I > clone DDS from github and install \n'
git clone https://github.com/LowellInstruments/dds.git $FOL_DDS


# X/. means the content excluding the folder X
printf 'I > restore dl_files from /tmp\n'
if [ $DONE_BAK -eq 1 ]; then mkdir $FOL_DLF || true; cp -r "$TSTAMP"/. $FOL_DLF; fi


printf 'I > ensuring resolv.conf \n'
sudo chattr -i /etc/resolv.conf
sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
sudo sh -c "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf"
sudo chattr +i /etc/resolv.conf


printf 'I > python base & DDH OK \n'
