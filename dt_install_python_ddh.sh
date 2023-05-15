#!/usr/bin/env bash


# create + call it
_is_rpi() {
    grep Raspberry /proc/cpuinfo; rv=$?
    if [ $rv -eq 0 ]; then IS_RPI=1; else IS_RPI=0; fi
}; _is_rpi


if [ $IS_RPI -eq 1 ]; then
    F_LI=/home/pi/li
else
    F_LI=$HOME/PycharmProjects/
fi
F_DA="$F_LI"/ddh
F_DT="$F_LI"/ddt
F_VE="$F_LI"/venv
F_TV=tmp/venv
VPIP=$F_TV/bin/pip
F_CLONE_MAT=/tmp/mat
F_CLONE_DDH=/tmp/ddh


_is_update_or_install() {
    if [ -d "$F_VE" ]; then
        IS_UPDATE=1
    else
        IS_UPDATE=0
    fi
}; _is_update_or_install


FLAG_DEBUG=0
FLAG_WE_RAN_THIS_SCRIPT=/tmp/ddh_we_ran_update_script.flag
FLAG_DDH_UPDATED=/tmp/ddh_got_update_file.flag
GH_REPO_DDH=https://github.com/lowellinstruments/ddh.git
GH_REPO_MAT=https://github.com/lowellinstruments/mat.git
GH_REPO_LIU=https://github.com/lowellinstruments/liu.git
if [ $IS_RPI -eq 1 ]; then
    DDH_REQS_TXT=requirements_rpi_39.txt
    # needed for crontab to access the X-window system
    export XAUTHORITY=/home/pi/.Xauthority
    export DISPLAY=:0
else
    DDH_REQS_TXT=requirements_dev_39.txt
fi


_flag_we_run_this() {
    # useful when debugging to know if this is being launched
    rm $FLAG_WE_RAN_THIS_SCRIPT || true
    touch $FLAG_WE_RAN_THIS_SCRIPT
}


_s() {
    # a progress bar dialog cannot change font size :( let's uppercase
    # src: https://funprojects.blog/2021/01/25/zenity-command-line-dialogs/
    # echo "#""${1^^}";
    # normal case
    echo "#""${1}"
}

_st() {
    _s "$1"
    sleep 2
}

_e() {
    # both GUI and console
    _s "error: ""$1"
    echo "error: ""$1"
    sleep 2
    exit 1
}

_check_ddh_update_flag() {
    # on laptop, we leave
    if [ $IS_RPI -eq 0 ]; then return; fi

    # debug always clears the flag
    if [ $FLAG_DEBUG -eq 1 ]; then rm $FLAG_DDH_UPDATED; fi
    if [ -f $FLAG_DDH_UPDATED ]; then
        printf "Already ran updater today, leaving!\n";
        exit 1
    fi
    touch $FLAG_DDH_UPDATED
}

_kill_ddh() {
    _st "killing running DDH, if any"
    "$F_DA"/scripts/kill_ddh.sh
}

_internet() {
    ping -q -c 1 -W 2 www.google.com; rv=$?;
    if [ $rv -ne 0 ]; then _e "no internet"; fi
}

_get_gh_commit_ddh() {
    COM_DDH_GH=$(git ls-remote $GH_REPO_DDH master | awk '{ print $1 }'); rv=$?;
    if [ "$rv" -ne 0 ]; then _e "cannot get DDH github version"; fi
    if [ ${#COM_DDH_GH} -ne 40 ]; then _e "bad DDH github version"; fi
    # _s "got DDH github commit \n""$COM_DDH_GH"
}

_get_gh_commit_mat() {
    COM_MAT_GH=$(git ls-remote $GH_REPO_MAT master | awk '{ print $1 }'); rv=$?;
    if [ "$rv" -ne 0 ]; then _e "cannot get MAT github version"; fi
    if [ ${#COM_MAT_GH} -ne 40 ]; then _e "bad MAT github version"; fi
    # _s "got MAT github commit \n""$COM_MAT_GH"
}

_get_local_commit_ddh() {
    if [ ! -d "$F_DA" ]; then return; fi
    COM_DDH_LOC=$(cd "$F_DA" && git rev-parse master); rv=$?;
    if [ "$rv" -ne 0 ]; then _e "cannot get DDH local version"; fi
    if [ ${#COM_DDH_LOC} -ne 40 ]; then _e "bad DDH local version"; fi
    # _s "got local DDH commit \n""$COM_DDH_LOC"
}

_virtual_env() {
    if [ $IS_UPDATE -eq 1 ]; then
        _st "Re-using existing VENV $F_VE folder";
        return;
    fi

    _s "VENV generating temporary folder $F_TV"
    rm -rf $F_TV || true
    rm -rf "$HOME"/.cache/pip
    # on RPi, venv needs to inherit PyQt5 installed via apt
    python3 -m venv "$F_TV" --system-site-packages; rv=$?
    if [ $rv -ne 0 ]; then _e "VENV cannot create folder $F_TV"; fi
    source "$F_TV"/bin/activate; rv=$?
    if [ $rv -ne 0 ]; then _e "VENV cannot activate"; fi
    "$VPIP" install --upgrade pip
    "$VPIP" install wheel
}

_ddh_install() {
    if [ "$COM_DDH_LOC" == "$COM_DDH_GH" ]; then
        if [ $IS_RPI -eq 1 ] && [ $FLAG_DEBUG -eq 0 ]; then
            _st "Already latest DDH :)"
            exit 0
        fi
        # on laptop, we keep going
    fi

    _s "Installing LIU library"
    "$VPIP" uninstall -y liu
    "$VPIP" install --upgrade git+$GH_REPO_LIU; rv=$?
    if [ "$rv" -ne 0 ]; then _e "cannot install LIU library"; fi

    _s "Cloning MAT library"
    rm -rf $F_CLONE_MAT; git clone $GH_REPO_MAT $F_CLONE_MAT; rv=$?
    if [ "$rv" -ne 0 ]; then _e "cannot clone MAT repository"; fi

    _s "Installing MAT library"
    cp $F_CLONE_MAT/tools/_setup_wo_reqs.py $F_CLONE_MAT/setup.py; rv=$?
    if [ "$rv" -ne 0 ]; then _e "cannot copy MAT empty setup.py"; fi
    "$VPIP" uninstall -y mat; "$VPIP" install $F_CLONE_MAT; rv=$?
    if [ $rv -ne 0 ]; then _e "cannot install MAT library"; fi

    _s "Cloning DDH"
    rm -rf $F_CLONE_DDH; git clone $GH_REPO_DDH $F_CLONE_DDH; rv=$?
    if [ $rv -ne 0 ]; then _e "cannot clone DDH"; fi

    _s "Installing DDH file $DDH_REQS_TXT"
    "$VPIP" install -r "$F_CLONE_DDH"/$DDH_REQS_TXT; rv=$?
    if [ $rv -ne 0 ]; then _e "cannot install DDH requirements"; fi


    if [ $IS_UPDATE -eq 1 ]; then
        _st "Saving current DDH settings"
        cp -r "$F_DA"/dl_files "$F_CLONE_DDH"
        cp -r "$F_DA"/logs "$F_CLONE_DDH"
        cp "$F_DA"/run_dds.sh "$F_CLONE_DDH"
        cp "$F_DA"/settings/ddh.json "$F_CLONE_DDH"/settings
        cp "$F_DA"/settings/ctx.py "$F_CLONE_DDH"/settings
        cp "$F_DA"/settings/_macs_to_sn.yml "$F_CLONE_DDH"/settings
        cp "$F_DA"/settings/_li_all_macs_to_sn.yml "$F_CLONE_DDH"/settings
        cp "$F_DT"/_dt_files/ble_dl_moana.py "$F_CLONE_DDH"/dds
    fi


    # on laptop, we end here
    if [ $IS_RPI -eq 0 ]; then
        _st "Detected non-rpi, leaving"
        return;
    fi

    _s "Uninstalling old DDH folder"
    if [ -d "$F_DA" ]; then
        rm -rf "$F_DA"; rv=$?
        if [ $rv -ne 0 ]; then
            _e "cannot delete old DDH folder";
        fi
    fi

    _s "Installing new DDH folder"
    mv "$F_CLONE_DDH" "$F_DA"; rv=$?
    if [ $rv -ne 0 ]; then
        _e "cannot install new DDH folder";
    fi

    _s "Installing new VENV folder"
    mv "$F_TV" "$F_LI"; rv=$?
    if [ $rv -ne 0 ]; then
        _e "cannot install new VENV folder";
    fi
}

_ddh_resolv_conf() {
    if [ "$IS_RPI" -eq 0 ]; then return; fi
    sudo chattr -i /etc/resolv.conf; rv=$?
    if [ $rv -ne 0 ]; then _e "cannot chattr -i resolv.conf"; fi
    sudo sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"; rv=$?
    if [ $rv -ne 0 ]; then _e "cannot nameserver_1 resolv.conf"; fi
    sudo sh -c "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf"; rv=$?
    if [ $rv -ne 0 ]; then _e "cannot nameserver_2 resolv.conf"; fi
    sudo chattr +i /etc/resolv.conf; rv=$?
    if [ $rv -ne 0 ]; then _e "cannot chattr +i resolv.conf"; fi
}

_done()
{
    _st "Done!"
}


_flag_we_run_this
_check_ddh_update_flag
(
  sleep 1; # so we can see first text
  echo 1; _kill_ddh
  echo 5; _internet
  echo 10; _get_gh_commit_mat
  echo 15; _get_gh_commit_ddh
  echo 20; _get_local_commit_ddh
  echo 30; _virtual_env
  echo 60; _ddh_install
  echo 98; _ddh_resolv_conf
  echo 99; _done
) | zenity --width=400 --title "DDH Installer" \
  --progress --auto-kill --auto-close \
  --icon-name="dialog-info" --window-icon="coffee.png" \
  --text="starting DDH updater"

# so terminal is left open for a couple ENTER keys
if [ $FLAG_DEBUG -eq 1 ]; then
    read -r; read -r
fi

# implicit exit 0 :)
