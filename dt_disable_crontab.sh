#!/usr/bin/env bash


LI=/home/pi/li
DDT=$LI/ddh_tools


# abort upon any error
clear && echo && set -e
trap 'echo ‘$BASH_COMMAND’ TRAPPED! rv $?' EXIT


echo; echo 'I > crontab_dis'
sudo cp $DDT/_dt_files/crontab_dis /etc/crontab
sudo chmod 644 /etc/crontab
sudo service cron reload

