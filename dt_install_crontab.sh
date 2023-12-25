#!/usr/bin/env bash


F_DT=/home/pi/li/ddt


function install_crontab {
    source dt_utils.sh
    _pb "INSTALL CRONTAB"

    sudo cp "$F_DT"/_dt_files/crontab /etc/crontab && \
    sudo chmod 644 /etc/crontab && \
    sudo service cron reload
    _e $? "install crontab"
}