#!/usr/bin/bash



source /home/pi/li/ddh/scripts/utils.sh
source /home/pi/li/ddt/bash_sdk/src/say.sh
source /home/pi/li/ddt/bash_sdk/src/spinner.sh




# for development
grep aspberry /proc/cpuinfo
rv=$?
if [ $rv -eq 0 ]; then
    source /home/kaz/PycharmProjects/ddt/bash_sdk/src/spinner.sh
else
    source "dt_utils.sh"
    _e 3 "this is not a raspberry"
fi



# DDU constants
clear
echo
echo
FTS=/tmp/ddh_stash
NUM_TASKS=12
F_CLONE_MAT=/tmp/mat



# detect UV tool presence
BIN_UV="/home/pi/.local/bin/uv"
$BIN_UV --version  >/dev/null 2>&1
rv=$?
if [ $rv -ne 0 ]; then
    # try to install it
    FOL_BIN_UV="$FOL_PI"/.local/bin
    mkdir -p "$FOL_BIN_UV"
    cp "$FOL_DDT"/_dt_files/uv "$FOL_BIN_UV"  && \
    cp "$FOL_DDT"/_dt_files/uvx "$FOL_BIN_UV"
fi



# decide flavor of pip
BIN_PIP="/home/pi/.local/bin/uv pip -q"
$BIN_UV --version  >/dev/null 2>&1
rv=$?
if [ $rv -ne 0 ]; then
    # --------------------------------------
    # we have no UV, just pip then, slower
    # --------------------------------------
    BIN_PIP="$FOL_VEN/bin/pip -q"
fi





i_num=1
spinner.start "  $i_num / $NUM_TASKS Updating" "ddh tools DDT"
    (cd "$FOL_DDT" && \
    git reset --hard && \
    git pull --quiet) > /dev/null
rv=$?
spinner.stop
_e $rv "error updating DDT"
((i_num++))





spinner.start "  $i_num / $NUM_TASKS Install " "LI MAT library"
"$FOL_VEN"/bin/python3 -c "import mat" 2> /dev/null
rv=$?
if [ $rv -ne 0 ]; then
    $BIN_PIP uninstall --python "$FOL_VEN"/bin/python3 mat > /dev/null
    rm -rf $F_CLONE_MAT
    git clone --quiet https://github.com/lowellinstruments/mat.git $F_CLONE_MAT --depth 1 > /dev/null
    rv=$?
    if [ $rv -ne 0 ]; then
        spinner.stop
        _e $rv "error cloning library MAT"
    fi
    cp $F_CLONE_MAT/tools/_pyproject_wo_reqs.toml $F_CLONE_MAT/pyproject.toml
    rm $F_CLONE_MAT/setup.py || true
    $BIN_PIP install --python "$FOL_VEN"/bin/python3 --no-deps $F_CLONE_MAT > /dev/null
    rv=$?
    spinner.stop
    _e $rv "error installing library MAT"
    COM_MAT_LOC=$(cd "$F_CLONE_MAT" && git rev-parse master)
    rv=$?
    _e $rv "cannot get MAT local commit file"
    if [ ${#COM_MAT_LOC} -ne 40 ]; then
        _e 1 "bad MAT $COM_MAT_LOC local commit file"
        exit 1
    fi
    sudo echo "$COM_MAT_LOC" | sudo tee /etc/com_mat_loc.txt > /dev/null
    rv=$?
    _e $rv "cannot copy MAT commit file to /etc/"
fi
((i_num++))







spinner.start "  $i_num / $NUM_TASKS Stashing" "DDH current configuration"
rm -rf $FTS
mkdir $FTS && \
# TOML files: config.toml, all_macs.toml, rerun_flag.toml
cp "$FOL_DDH"/settings/*.toml $FTS && \
cp "$FOL_DDH"/scripts/script_logger_dox_deploy_cfg.json $FTS
rv=$?
spinner.stop
_e $rv "stashing DDH current configuration files"
# might be there or not
cp "$FOL_DDH"/ddh/db/db_his.json $FTS 2> /dev/null
cp "$FOL_DDH"/.decided_scf_*.toml $FTS 2> /dev/null
((i_num++))





spinner.start "  $i_num / $NUM_TASKS Updating" "DDH code open source"
    (cd "$FOL_DDH" && \
    git reset --hard && \
    git pull --quiet) > /dev/null
rv=$?
spinner.stop
_e $rv "updating DDH code open source"
((i_num++))






spinner.start "  $i_num / $NUM_TASKS Install " "LI BLE library"
    $BIN_PIP install --python "$FOL_VEN"/bin/python3 --reinstall --no-deps \
        ble@git+https://github.com/LowellInstruments/ble.git\
        > /dev/null 2>&1
rv=$?
spinner.stop
_e $rv "installing DDH new LI BLE libraries"
((i_num++))





spinner.start "  $i_num / $NUM_TASKS Install " "LI GPS library"
    $BIN_PIP install --python "$FOL_VEN"/bin/python3 --reinstall --no-deps \
        gps@git+https://github.com/LowellInstruments/gps.git\
        > /dev/null 2>&1
rv=$?
spinner.stop
_e $rv "installing DDH new LI GPS libraries"
((i_num++))





spinner.start "  $i_num / $NUM_TASKS Install " "LI LIX library"
    $BIN_PIP install --python "$FOL_VEN"/bin/python3 --reinstall --no-deps \
        lix@git+https://github.com/LowellInstruments/lix.git\
        > /dev/null 2>&1
rv=$?
spinner.stop
_e $rv "installing DDH new LI LIX libraries"
((i_num++))




spinner.start "  $i_num / $NUM_TASKS Un-stash" "DDH current configuration"
    cp $FTS/*.toml "$FOL_DDH"/settings && \
    cp $FTS/script_logger_dox_deploy_cfg.json "$FOL_DDH"/scripts
rv=$?
spinner.stop
_e $rv "un-stashing DDH current configuration files"
    # might be there or not
    cp $FTS/db_his.json "$FOL_DDH"/ddh/db 2> /dev/null
    cp $FTS/.decided_scf_*.toml "$FOL_DDH" 2> /dev/null
((i_num++))




spinner.start "  $i_num / $NUM_TASKS Install " "some unfortunate file closed source not from LI"
    cp "$FOL_DDT"/_dt_files/ble_dl_moana.py "$FOL_DDH"/ddh
rv=$?
spinner.stop
_e $rv "installing closed source moana plugin"
((i_num++))





spinner.start "  $i_num / $NUM_TASKS Killing " "DDH application, it will auto-start"
    killall -q ddh_main || true
    sleep 1
    killall -9 -q ddh_main || true
spinner.stop
((i_num++))





spinner.start " $i_num / $NUM_TASKS Install " "DDT extra.sh"
    (cd "$FOL_DDT" && ./dt_install_extra.sh force) > /dev/null
rv=$?
spinner.stop
_e $rv "installing DDT extra"
    source /home/pi/.bashrc > /dev/null
rv=$?
_e $rv "sourcing bashrc"
((i_num++))




#spinner.start " $i_num / $NUM_TASKS Restart " "systemctl for new services"
#    # this would not work because /etc/ might be overlay
#    # sudo cp "$FOL_DDT"/_dt_files/unit_switch_net.service /etc/systemd/system/ && \
#    # sudo cp "$FOL_DDT"/_dt_files/unit_my_info.service /etc/systemd/system/ && \
#    sudo systemctl daemon-reload
#    sudo systemctl restart unit_switch_net.service
#    sudo systemctl enable unit_switch_net.service
#    sudo systemctl restart unit_my_info.service
#    sudo systemctl enable unit_my_info.service
#rv=$?
#spinner.stop
#_e $rv "restarting systemctl for new services"
#((i_num++))




spinner.start " $i_num / $NUM_TASKS Killing " "API, it will auto-start"
    killall -q main_api  || true
    killall -q main_api_controller || true
spinner.stop
((i_num++))


echo
