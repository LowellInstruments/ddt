#!/usr/bin/env bash



function read_api_pw_to_file {
    source dt_utils.sh
    read -rp "enter api pw: " api_pw
    # shellcheck disable=SC2086
    echo "$api_pw" > "$HOME"/.api_pw
}


# this script has a slightly different structure
clear && echo
echo "running dt_install_config.sh"


# step 1) call python script to get config.toml file
# password must be previously stored in file $HOME/.api_pw
api_pw=$(cat "$HOME"/.api_pw)
python3 _dt_files/_ddn_cli_api_cfg.py "$api_pw"
