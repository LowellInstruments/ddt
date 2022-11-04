#!/usr/bin/env bash


# grab variables from file
. ./_dt_files/dt_variables.sh || (echo 'dt_vars fail'; exit 1)


# abort upon any error
clear && echo && set -e
trap 'echo "$BASH_COMMAND" TRAPPED! rv $?' EXIT


echo; echo 'I > crontab'
sudo cp "$F_DT"/_dt_files/crontab /etc/crontab
sudo chmod 644 /etc/crontab
sudo service cron reload
