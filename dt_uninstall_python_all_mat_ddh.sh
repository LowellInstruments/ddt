#!/usr/bin/env bash



# grab vars from other script
. ./_dt_files/dt_variables.sh || (echo 'fail dt_vars'; exit 1)
echo


read -r -p "This will uninstall DDH. Are you sure? [y/N] " choice
if [ "$choice" != "y" ]; then
    printf 'not doing it! bye\n'
    exit 0
fi



# uninstalling
printf '[ DDH ] activating virtualenv to uninstall lowell-mat... \n'
source "$VENV"/bin/activate
printf '[ DDH ] uninstalling lowell-mat... \n'
"$VPIP" uninstall lowell-mat || true
if [ ! -d "$F_DA" ]; then
    printf "[ DDH ] app folder does not exist, skipping removal \n"
fi
printf '[ DDH ] uninstalling DDH application... \n'
rm -rf "$F_DA" || true
echo
