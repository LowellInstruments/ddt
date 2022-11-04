#!/usr/bin/env bash



# grab vars from other script
. ./_dt_files/dt_variables.sh || (echo 'fail dt_vars'; exit 1)
echo


read -r -p "This will uninstall DDH. Are you sure? [y/N] " choice
if [ "$choice" == "y" ]; then
    printf '[ DDH ] uninstall, activating virtualenv \n'
else
    printf 'bye'
fi



# uninstalling
source "$VENV"/bin/activate
"$VPIP" uninstall lowell-mat
rm -rf "$F_DA" || true

