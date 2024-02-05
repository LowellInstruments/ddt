#!/usr/bin/env bash
source dt_utils.sh


function install_crontab {
    title dt_install_crontab

    _pb "INSTALL CRONTAB"
    cd "$FOL_LI" || (_pe "error: bad working directory"; exit 1)


    sudo cp "$FOL_DDT"/_dt_files/crontab /etc/crontab && \
    sudo chmod 644 /etc/crontab && \
    sudo service cron reload
    _e $? "install crontab"
}