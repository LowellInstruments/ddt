#!/usr/bin/env bash
source dt_utils.sh



function install_step_1 {

    clear
    title step_1_linux


    _pb "CHECKING SYSTEM"
    [ "$(basename "$(pwd)")" == "ddt" ]
    rv=$?
    if [ $rv -ne 0 ]; then _pr "folder should be $FOL"; exit 1; fi
    file /usr/bin/file | grep "64-bit"
    _e $? "no 64-bits arch"
    _pb "creating $FOL_LI"
    mkdir "$FOL_LI" 2> /dev/null
    _pb "removing custom flags"
    rm "$GROUPED_S3_FILE_FLAG" 2> /dev/null
    rm "$DDH_USES_SHIELD_CELL_SIXFAB" 2> /dev/null
    rm "$DDH_USES_SHIELD_CELL_TWILIO" 2> /dev/null
    rm "$DDH_USES_SHIELD_JUICE4HALT" 2> /dev/null
    rm "$DDH_USES_SHIELD_SAILOR" 2> /dev/null
    _pb "setting grouped s3 flag"
    touch "$GROUPED_S3_FILE_FLAG"
    _pb "setting CELL shield to use SIXFAB"
    touch "$DDH_USES_SHIELD_CELL_SIXFAB"






     _pb "INSTALL LINUX DEPENDENCIES"
    sudo apt-get --yes update
    sudo apt-mark hold bluez
    sudo apt remove -y modemmanager
    sudo killall ModemManager
    sudo systemctl stop ModemManager
    sudo systemctl disable ModemManager
    sudo apt remove -y python3-numpy
    sudo apt-get --yes --assume-yes install minicom xscreensaver matchbox-keyboard ifmetric joe git \
    libatlas3-base libglib2.0-dev libhdf5-dev python3-dev \
    libgdal-dev libproj-dev proj-data proj-bin python3-gdbm python3-venv \
    libcurl4-gnutls-dev gnutls-dev python3-pycurl libdbus-1-dev libopenblas-dev \
    libudev-dev libical-dev libreadline-dev libcap-dev awscli python3-requests ninja-build wireguard \
    cmake xinput-calibrator x11-utils
    _e $? "apt-get"
    sudo apt-get --yes --assume-yes install redis
    sudo apt-get --yes --assume-yes install python3-pyqt6 pyqt6-dev-tools
    _pb 'apt-get clean'
    sudo apt autoremove -y
    sudo apt-get clean
    # Lowell Instruments DDH wallpaper
    export XAUTHORITY=/home/pi/.Xauthority
    export DISPLAY=:0
    pcmanfm --set-wallpaper "$FOL_DDT"/_dt_files/wp_ddh.jpg

    
    
    
    _pb "CONFIGURE REDIS"
    sudo systemctl stop redis
    sudo systemctl disable redis
    grep -qF "vm.overcommit_memory = 1" /etc/sysctl.conf || (echo "vm.overcommit_memory = 1" | sudo tee -a /etc/sysctl.conf)



    _pb "INSTALL POWER HATS"
    select POWEROPTION in "SailorHat" "Juice4Halt" 
    do
      case $POWEROPTION in
        "SailorHat")
          break
          ;;
      "Juice4Halt")
          break
          ;;
        *)
          echo "Invalid choice. Please try again."
          ;;
      esac
    done
    
    if [ $POWEROPTION == "SailorHat" ]; then
        _pb "For sailorhat, when asked, ``enable`` the first option (RTC) and ``skip`` \
        the remaining 3 (CAN, RS485, MAX-M8Q GNSS)."
        touch "$DDH_USES_SHIELD_SAILOR"
        _pb "unzipping sailorhat folder"
        FOL_TMP_SAH=/tmp/my_sailorhat
        rm -rf $FOL_TMP_SAH 2> /dev/null
        unzip "$FOL_DDT"/_dt_files/sh_rpi_daemon_224.zip -d $FOL_TMP_SAH
        _e $? "unzipping sailor_hat"
        _pb "modifying sailorhat couple of files"
        cp "$FOL_DDT"/_dt_files/sailor_const.py $FOL_TMP_SAH/SH-RPi-daemon-2.2.4/src/shrpi/const.py && \
        cp "$FOL_DDT"/_dt_files/sailor_sm.py $FOL_TMP_SAH/SH-RPi-daemon-2.2.4/src/shrpi/state_machine.py
        _e $? "modifying sailor_hat"
        _pb "installing modified sailorhat"
        cd $FOL_TMP_SAH/SH-RPi-daemon-2.2.4 && \
        sudo ./install.sh --enable RTC
        _e $? "installing sailor_hat"
        _pb 'creating sailor_hat pop-up'
        FOL_SAH="$FOL_LI"/sailorhat
        rm -rf "$FOL_SAH" 2> /dev/null
        mkdir "$FOL_SAH"
        sudo cp "$FOL_DDT"/_dt_files/popup_sah.sh "$FOL_SAH"
        _e $? "sailor_hat pop-up"
        _pb "checking sailor_hat service active"
        sudo systemctl enable shrpid
        sudo systemctl start shrpid
        sudo systemctl is-active shrpid.service | grep -w active
        _e $? "sailor_hat service NOT active"

    # juice4halt
    else
        touch "$DDH_USES_SHIELD_JUICE4HALT"
        FOL_J4H="$FOL_LI"/juice4halt
        sudo rm -rf "$FOL_J4H"
        _pb "juice4halt"
        mkdir -p "$FOL_J4H"/bin
        cp "$FOL_DDT"/_dt_files/shutdown_script.py "$FOL_J4H"/bin/
        cp "$FOL_DDT"/_dt_files/popup_j4h.sh "$FOL_J4H"/bin/
        _e $? "juice4halt"
        # just in case
        sudo systemctl disable shrpid
        sudo systemctl stop shrpid
    fi



    # rc.local runs display brightness, NTP, juice4halt, sailorhat
    _pb 'rc.local'
    sudo cp "$FOL_DDT"/_dt_files/rc.local /etc/rc.local && \
    sudo chmod +x /etc/rc.local && \
    sudo systemctl enable rc-local
    sudo systemctl restart rc-local
    _e $? "starting rc.local"
    # reduce number of journal logs
    _pb 'journald.conf'
    sudo cp "$FOL_DDT"/_dt_files/journald.conf /etc/systemd/
    sudo systemctl restart systemd-journald
    _pb "is rc.local active"
    sudo systemctl is-active rc-local
    _e $? "rc.local not active"











    




    _pb "INSTALL SERVICE_SW_NET"
    _pb "ifmetric"
    sudo setcap 'cap_net_raw,cap_net_admin+eip' /usr/sbin/ifmetric
    _e $? "ifmetric"
    _pb "switch_net_service"
    (sudo systemctl stop unit_switch_net.service || true) && \
    sudo cp "$FOL_DDT"/_dt_files/unit_switch_net.service /etc/systemd/system/ && \
    sudo chmod 644 /etc/systemd/system/unit_switch_net.service && \
    sudo systemctl daemon-reload && \
    (sudo systemctl disable unit_switch_net.service || true) && \
    sudo systemctl enable unit_switch_net.service && \
    sudo systemctl start unit_switch_net.service
    _e $? "starting switch net service"
    _pb "is switch_net_service active"
    systemctl is-active unit_switch_net.service | grep -w active
    _e $? "switch_net_service NOT active"



    _pb "INSTALL SERVICE MY INFO"
    (sudo systemctl stop unit_my_info.service || true) && \
    sudo cp "$FOL_DDT"/_dt_files/unit_my_info.service /etc/systemd/system/ && \
    sudo chmod 644 /etc/systemd/system/unit_my_info.service && \
    sudo systemctl daemon-reload && \
    (sudo systemctl disable unit_my_info.service || true) && \
    sudo systemctl enable unit_my_info.service && \
    sudo systemctl start unit_my_info.service
    _e $? "starting my info service"
    _pb "is my_info_service active"
    systemctl is-active unit_my_info.service | grep -w active
    _e $? "my_info_service NOT active"



    _pb "INSTALL CRONTAB"
    sudo cp "$FOL_DDT"/_dt_files/crontab /etc/crontab && \
    sudo chmod 644 /etc/crontab && \
    sudo service cron reload
    _e $? "install crontab"




    _pb "INSTALLING PPP SIXFAB"
    sudo "$FOL_DDT"/_dt_files/ppp_install_sixfab.sh




    _pb "INSTALLING BLUEZ"
    # this seems to minimize the number of BLE hardware errors
    grep "aspberry Pi 3" /proc/cpuinfo
    rv=$?
    if [ $rv -eq 0 ]; then
        _pb "btuart"
        sudo cp "$FOL_DDT"/_dt_files/btuart /usr/bin/ && \
        sudo chown root /usr/bin/btuart && \
        sudo chgrp root /usr/bin/btuart
        _e $? "btuart patch for rpi"
    fi



    # 5.66 from DDHv4 worked fine but a bit old, lets update to 5.82
    _pb "checking current bluez version"
    bluetoothctl -v | grep "5.82"
    rv=$?
    if [ $rv -eq 0 ]; then
        _pg "bluez already version 5.82"
    else
        _pb "bluez"
        cd "$FOL_DDT"/_dt_files && \
        wget -O bluez-5.82.tar.gz https://github.com/bluez/bluez/archive/refs/tags/5.82.tar.gz
        _e $? "download bluez"
        tar xvf bluez-5.82.tar.gz && \
        cd bluez-5.82
        _e $? "uncompress bluez"
        _pb "installing bluez dependencies"
        sudo apt-get -y install libelf-dev elfutils libdw-dev libasound2-dev libell-dev libsbc-dev libspeexdsp-dev
        ./bootstrap-configure --enable-external-ell
        ./configure && \
        make && \
        sudo make install && \
        cd "$FOL_DDT"/_dt_files && \
        rm -rf bluez-5.82*
        _e $? "install bluez"
    fi







    _pb "INSTALL USEFUL ALIASES"
    F_RC=/home/pi/.bashrc
    grep 'alias cdh' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias cdh=\"cd /home/pi/li/ddh\"" >> $F_RC
    fi
    grep 'alias cdt' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias cdt=\"cd /home/pi/li/ddt\"" >> $F_RC
    fi
    grep 'alias ace' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias ace=\"nano /home/pi/li/ddh/settings/config.toml\"" >> $F_RC
    fi
    grep 'alias acs' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias acs=\"cat /home/pi/li/ddh/settings/config.toml\"" >> $F_RC
    fi
    grep 'alias vdh' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias vdh=\"source /home/pi/li/venv/bin/activate\"" >> $F_RC
    fi
    sed -i '/alias ddc/d' $F_RC
    echo "alias ddc=\"/home/pi/li/ddh/run_ddc.sh\"" >> $F_RC
    sed -i '/alias ddu/d' $F_RC
    echo "alias ddu=\"cd /home/pi/li/ddt; ./pop_ddh.sh\"" >> $F_RC
    grep 'alias olr' $F_RC
    rv=$?
    if [ $rv -ne 0 ]; then
        echo "alias olr=\"sudo overlayroot-chroot\"" >> $F_RC
    fi
}


# when calling this file
install_step_1

