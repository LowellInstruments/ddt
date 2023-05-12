#!/usr/bin/env bash

# create + call it
_is_rpi() {
    grep Raspberry /proc/cpuinfo; rv=$?
    if [ $rv -eq 0 ]; then IS_RPI=1; else IS_RPI=0; fi
}; _is_rpi


FLAG_DEBUG=1
FLAG_DDH_UPDATED=/tmp/ddh_got_update_file.flag
GH_REPO_DDH=https://github.com/lowellinstruments/ddh.git
GH_REPO_MAT=https://github.com/lowellinstruments/mat.git
GH_REPO_LIU=https://github.com/lowellinstruments/liu.git
if [ $IS_RPI -eq 1 ]; then
    F_LI=/home/pi/li
    DDH_REQS_TXT=requirements_rpi_39.txt
else
    F_LI=/home/kaz/PycharmProjects
    DDH_REQS_TXT=requirements_dev_39.txt
fi
F_DA="$F_LI"/ddh
F_DT="$F_LI"/ddt
F_CLONE_MAT=/tmp/mat
F_CLONE_DDH=/tmp/ddh
F_VE=/tmp/venv
VPIP=$F_VE/bin/pip


_s() {
    # a progress bar dialog cannot change font size :( let's uppercase
    # src: https://funprojects.blog/2021/01/25/zenity-command-line-dialogs/
    # echo "#""${1^^}";
    # normal case
    echo "#""${1}";
}

_st() {
    _s "$1"; sleep 2
}

_e() {
    _s "error: ""$1"; sleep 2; exit 1
}

_check_ddh_update_flag() {
    # on laptop, keep going
    if [ $IS_RPI -eq 0 ]; then return; fi
    if [ $FLAG_DEBUG -eq 1 ]; then rm $FLAG_DDH_UPDATED; fi
    if [ -f $FLAG_DDH_UPDATED ]; then
      _st "Already ran updater today, leaving!";
      exit 1
      fi
    touch $FLAG_DDH_UPDATED
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
    if [ -d $F_VE ]; then _st "Re-using existing VENV folder"; return; fi
    _s "VENV generating folder $F_VE"
    rm -rf "$F_VE"
    rm -rf "$HOME"/.cache/pip
    # on RPi, venv needs to inherit PyQt5 installed via apt
    python3 -m venv "$F_VE" --system-site-packages; rv=$?
    if [ $rv -ne 0 ]; then _e "VENV cannot create folder $F_VE"; fi
    source "$F_VE"/bin/activate; rv=$?
    if [ $rv -ne 0 ]; then _e "VENV cannot activate"; fi
    "$VPIP" install --upgrade pip
    "$VPIP" install wheel
}

_ddh_update() {
    if [ "$COM_DDH_LOC" == "$COM_DDH_GH" ]; then
        if [ $IS_RPI -eq 1 ]; then _st "Already latest DDH :)"; exit 0; fi
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

    if [ -d $F_DA ]; then _st "Saving current DDH settings"; fi
    # it just works OK either already there or not
    cp -r "$F_DA"/dl_files "$F_CLONE_DDH"
    cp -r "$F_DA"/logs "$F_CLONE_DDH"
    cp "$F_DA"/run_dds.sh "$F_CLONE_DDH"
    cp "$F_DA"/settings/ddh.json "$F_CLONE_DDH"/settings
    cp "$F_DA"/settings/ctx.py "$F_CLONE_DDH"/settings
    cp "$F_DA"/settings/_macs_to_sn.yml "$F_CLONE_DDH"/settings
    cp "$F_DA"/settings/_li_all_macs_to_sn.yml "$F_CLONE_DDH"/settings
    cp "$F_DT"/_dt_files/ble_dl_moana.py "$F_CLONE_DDH"/dds

    # on laptop, we end here
    if [ $IS_RPI -eq 0 ]; then
        _st "Detected non-rpi, leaving"
        return;
    fi

    _s "Uninstalling old DDH folder"
    if [ -d $F_DA ]; then
        rm -rf "$F_DA"; rv=$?
        if [ $rv -ne 0 ]; then _e "cannot delete old DDH folder"; fi
    fi

    _s "Installing new DDH folder"
    mv "$F_CLONE_DDH" "$F_DA"; rv=$?
    if [ $rv -ne 0 ]; then _e "cannot install new DDH folder"; fi
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


(
  sleep 1; # so we can see first text
  echo 1; _check_ddh_update_flag
  echo 5; _internet
  echo 10; _get_gh_commit_mat
  echo 15; _get_gh_commit_ddh
  echo 20; _get_local_commit_ddh
  echo 30; _virtual_env
  echo 60; _ddh_update
  echo 98; _ddh_resolv_conf
  echo 99; _done
) | zenity --width=400 --title "-- DDH INSTALLER --" \
  --progress --auto-kill --auto-close \
  --icon-name="dialog-info" --window-icon="coffee.png" \
  --text="starting DDH updater"

# so terminal is left open for a couple ENTER keys
read -r; read -r

# implicit exit 0 :)
