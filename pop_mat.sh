#!/usr/bin/bash



source /home/pi/li/ddh/scripts/utils.sh
clear


F_CLONE_MAT=/tmp/mat



_S="[ POP ] mat | activating VENV"
_pb "$_S"
source "$FOL_VEN"/bin/activate
_e $? "$_S"



_S="[ POP ] mat | uninstalling previous library, if any"
_pb "$_S"
"$FOL_VEN"/bin/pip3 uninstall -y mat
_e $? "$_S"



_S="[ POP ] mat | cloning newest code from github to /tmp"
_pb "$_S"
rm -rf $F_CLONE_MAT
git clone https://github.com/lowellinstruments/mat.git $F_CLONE_MAT
_e $? "$_S"



_S="[ POP ] mat | installing it via pip"
_pb "$_S"
"$FOL_VEN"/bin/pip3 install $F_CLONE_MAT
_e $? "$_S"



_S="[ POP ] mat | creating commit local file"
_pb "$_S"
COM_MAT_LOC=$(cd "$F_CLONE_MAT" && git rev-parse master)
_e $? "cannot get MAT local commit file"
[ ${#COM_MAT_LOC} -eq 40 ]
_e $? "bad MAT $COM_MAT_LOC local commit file"
sudo echo "$COM_MAT_LOC" | sudo tee /etc/com_mat_loc.txt > /dev/null
_e $? "cannot copy MAT commit file to /etc/"



_pb "[ POP ] mat | done OK!"

