#!/usr/bin/env bash
source dt_utils.sh




function install_dws {

    title dt_install_dws


    _pb "DOWNLOADING but not INSTALLING DWS:"


    cd "$FOL_PI"/Downloads && \
    wget https://www.dwservice.net/download/dwagent.sh && \
    chmod +x "$FOL_PI"/Downloads/dwagent.sh && \
    _py "use 7-digit code created in your DWS account to add this host" && \
    _py "we left the DWS installer in $FOL_PI/Downloads"
}
