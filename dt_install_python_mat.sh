#!/usr/bin/env bash


# grab variables from file
. ./dt_variables.sh || (echo 'dt_vars fail'; exit 1)


printf '\n\n\n---- Install MAT ----\n'

printf '\nI > MAT library...\n'
source "$VENV"/bin/activate

pip install git+https://github.com/lowellinstruments/lowell-mat.git@v4

printf 'I > MAT library OK\n'
