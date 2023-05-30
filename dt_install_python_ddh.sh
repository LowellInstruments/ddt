#!/usr/bin/env bash


# check this script is already running
S_ME=$(basename "$0")
N_ME=$(pgrep -afc "$S_ME")
if [ "$N_ME" -ne 1 ]; then
    echo "error: $S_ME already running, leaving"
    exit 1
fi


# detect we are on Raspberry pi
_is_rpi() {
    grep Raspberry /proc/cpuinfo; rv=$?
    if [ $rv -eq 0 ]; then FLAG_IS_RPI=1; else FLAG_IS_RPI=0; fi
}
_is_rpi


# specific laptop vs RPi variables
if [ $FLAG_IS_RPI -eq 1 ]; then
    F_LI=/home/pi/li
    DDH_REQS_TXT=requirements_rpi_39.txt
    # needed for crontab to access the X-window system
    export XAUTHORITY=/home/pi/.Xauthority
    export DISPLAY=:0
else
    F_LI=$HOME/PycharmProjects/
    DDH_REQS_TXT=requirements_dev_39.txt
fi


# ignores everything and force software download
FLAG_FORCE=0; if [ "$1" == "force" ]; then FLAG_FORCE=1; fi


# common variables for laptop and RPi
F_DA="$F_LI"/ddh
F_DT="$F_LI"/ddt
F_VE="$F_LI"/venv
F_VO="$F_LI"/venv_old
VPIP=$F_VE/bin/pip
F_CLONE_MAT=/tmp/mat
F_CLONE_DDH=/tmp/ddh
GH_REPO_DDH=https://github.com/lowellinstruments/ddh.git
GH_REPO_MAT=https://github.com/lowellinstruments/mat.git
GH_REPO_LIU=https://github.com/lowellinstruments/liu.git
FLAG_DDH_UPDATED=/tmp/ddh_got_update_file.flag


_s() {
    # progress bar dialog cannot change font size :( maybe uppercase
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


_check_flag_ddh_update() {
    if [ -f $FLAG_DDH_UPDATED ] && [ $FLAG_FORCE -eq 0 ]; then
        printf "bye! already ran updater today \n";
        exit 1
    fi
    touch $FLAG_DDH_UPDATED
}


_kill_ddh() {
    _st "DDH - killing any currently running application"
    "$F_DA"/scripts/kill_ddh.sh 2> /dev/null
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
    if [ ! -d "$F_DA" ]; then
        return
    fi
    COM_DDH_LOC=$(cd "$F_DA" && git rev-parse master); rv=$?;
    if [ "$rv" -ne 0 ]; then _e "cannot get DDH local version"; fi
    if [ ${#COM_DDH_LOC} -ne 40 ]; then _e "bad DDH local version"; fi
    # _s "got local DDH commit \n""$COM_DDH_LOC"
}


_get_local_commit_mat() {
    COM_MAT_LOC=$(cat /etc/com_mat_loc.txt 2> /dev/null)
}


_restore_old_venv() {
    # this only gets called on error
    _st "VENV - restoring $F_VO"
    rm -r "$F_VE"
    mv "$F_VO" "$F_VE"
    if [ $rv -ne 0 ]; then
        _e "cannot restore old VENV";
    fi
    exit 1
}


_detect_need() {
    if [ $FLAG_FORCE -eq 1 ]; then
        _st "DDH - detected FORCE flag"
        return
    fi

    # debug
    if [ "$COM_MAT_LOC" == "$COM_MAT_GH" ]; then
        _st "DETECTED NEWEST MAT version"
    fi


    if [ "$COM_DDH_LOC" == "$COM_DDH_GH" ] && [ "$COM_MAT_LOC" == "$COM_MAT_GH" ]; then
        # on laptop testing, we keep going
        if [ $FLAG_IS_RPI -eq 1 ]; then
            _st "DDH - bye! newest app already installed"
            exit 0
        fi
    fi
}


_create_venv() {
    if [ -d "$F_VE" ]; then
        _st "VENV - stashing old as $F_VO";
        mv "$F_VE" "$F_VO"
        if [ $rv -ne 0 ]; then
            _e "cannot stash old VENV";
        fi
    fi

    # create VENV, inherit PyQt5 installed via apt
    _s "VENV - creating $F_VE"
    rm -rf "$HOME"/.cache/pip 2> /dev/null
    python3 -m venv "$F_VE" --system-site-packages
    rv=$?
    if [ $rv -ne 0 ]; then
        _st "error: cannot create $F_VE"
        _restore_old_venv
    fi

    source "$F_VE"/bin/activate
    rv=$?
    if [ $rv -ne 0 ]; then
        _st "error: cannot activate $F_VE"
        _restore_old_venv
    fi
    "$VPIP" install --upgrade pip
    "$VPIP" install wheel
}


_install() {
    _s "VENV - installing LIU library"
    "$VPIP" uninstall -y liu
    "$VPIP" install --upgrade git+$GH_REPO_LIU
    rv=$?
    if [ "$rv" -ne 0 ]; then
        _st "error: cannot install LIU library";
        _restore_old_venv
    fi

    _s "VENV - cloning MAT library"
    rm -rf $F_CLONE_MAT 2> /dev/null
    git clone $GH_REPO_MAT $F_CLONE_MAT
    rv=$?
    if [ "$rv" -ne 0 ]; then
        _st "error: cannot clone MAT repository";
        _restore_old_venv
    fi

    _s "VENV - installing MAT library"
    cp $F_CLONE_MAT/tools/_setup_wo_reqs.py $F_CLONE_MAT/setup.py
    rv=$?
    if [ "$rv" -ne 0 ]; then
        _st "error: cannot copy MAT empty setup.py";
        _restore_old_venv
    fi
    "$VPIP" uninstall -y mat
    "$VPIP" install $F_CLONE_MAT
    rv=$?
    if [ $rv -ne 0 ]; then
        _st "error: cannot install MAT library";
        _restore_old_venv
    fi

    _st "VENV - storing last MAT library git commit string"
    if [ $FLAG_IS_RPI ]; then
        COM_MAT_LOC=$(cd "$F_CLONE_MAT" && git rev-parse master); rv=$?;
        if [ "$rv" -ne 0 ]; then _e "cannot get MAT local version"; fi
        if [ ${#COM_DDH_LOC} -ne 40 ]; then _e "bad MAT local version"; fi
        sudo sh -c 'echo $COM_MAT_LOC > /etc/com_mat_loc.txt'
    fi

    _s "VENV - cloning DDH"
    rm -rf $F_CLONE_DDH
    git clone $GH_REPO_DDH $F_CLONE_DDH
    rv=$?
    if [ $rv -ne 0 ]; then
        _st "error: cannot clone DDH";
        _restore_old_venv
    fi

    _s "VENV - installing $DDH_REQS_TXT"
    "$VPIP" install -r "$F_CLONE_DDH"/$DDH_REQS_TXT
    rv=$?
    if [ $rv -ne 0 ]; then
        _st "error: cannot install DDH requirements";
        _restore_old_venv
    fi

    _s "VENV - removing old $F_VO"
    rm "$F_VO" 2> /dev/null

    if [ -d "$F_DA" ]; then
        _st "DDH - saving existing settings"
        cp -r "$F_DA"/dl_files "$F_CLONE_DDH"
        cp -r "$F_DA"/logs "$F_CLONE_DDH"
        cp "$F_DA"/run_dds.sh "$F_CLONE_DDH"
        cp "$F_DA"/settings/ddh.json "$F_CLONE_DDH"/settings
        cp "$F_DA"/settings/ctx.py "$F_CLONE_DDH"/settings
        cp "$F_DA"/settings/_macs_to_sn.yml "$F_CLONE_DDH"/settings
        cp "$F_DA"/settings/_li_all_macs_to_sn.yml "$F_CLONE_DDH"/settings
        cp "$F_DT"/_dt_files/ble_dl_moana.py "$F_CLONE_DDH"/dds
    fi

    # on laptop we stop here, don't really install
    if [ $FLAG_IS_RPI -eq 0 ]; then
        _st "DDH - detected non-rpi, not installing, leaving"
        return;
    fi

    if [ -d "$F_DA" ]; then
        _s "DDH - deleting old application folder"
        rm -rf "$F_DA"
        rv=$?
        if [ $rv -ne 0 ]; then
            _e "cannot delete old DDH folder";
        fi
    fi

    _s "DDH - installing new application folder"
    mv "$F_CLONE_DDH" "$F_DA"
    rv=$?
    if [ $rv -ne 0 ]; then
        _e "cannot install new DDH folder";
    fi
}


_resolv_conf() {
    # on laptop, don't mess with resolv.conf
    if [ "$FLAG_IS_RPI" -eq 0 ]; then return; fi
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



_check_flag_ddh_update
(
  sleep 1; # so we can see first text
  echo 1; _kill_ddh
  echo 5; _internet
  echo 10; _get_gh_commit_mat
  echo 15; _get_gh_commit_ddh
  echo 20; _get_local_commit_ddh
  echo 22; _get_local_commit_mat
  echo 25; _detect_need "$1"
  echo 30; _create_venv
  echo 60; _install
  echo 98; _resolv_conf
  echo 99; _done
  echo 100; _done
) | zenity --width=400 --title "DDH Installer" \
  --progress --auto-kill --auto-close \
  --icon-name="dialog-info" --window-icon="coffee.png" \
  --text="DDH Installer"


# implicit exit 0 :)
