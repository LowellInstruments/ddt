#!/usr/bin/env bash


F_LI=/home/pi/li
F_DT=/home/pi/li/ddt


function install_crontab {
    source dt_utils.sh
    _pb "INSTALL CRONTAB"
    cd $F_LI || (_pe "error: bad working directory"; exit 1)


    sudo cp "$F_DT"/_dt_files/crontab /etc/crontab && \
    sudo chmod 644 /etc/crontab && \
    sudo service cron reload
    _e $? "install crontab"
}