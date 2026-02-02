#!/usr/bin/env bash
source dt_utils.sh



function install_step_4 {

    clear
    title dt_install_dws


    _pb "DOWNLOADING but not INSTALLING DWS"
    wget https://www.dwservice.net/download/dwagent.sh -O "$FOL_PI"/Downloads/dwagent.sh && \
    chmod +x "$FOL_PI"/Downloads/dwagent.sh && \
    _py "DWS installer downloaded in $FOL_PI/Downloads, add it to your account"
    _e $? "DWS"
}



# when calling this file
install_step_4
