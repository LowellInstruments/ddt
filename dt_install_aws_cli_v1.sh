#!/usr/bin/env bash


# you may need to install python3-venv


# abort upon any error
clear && echo && set -e
trap 'echo ‘$BASH_COMMAND’ TRAPPED! rv $?' EXIT


# unzip our file in _dt_files
cd _dt_files && unzip awscli-bundle.zip


# install it
echo; echo 'I > install AWS cli v1'
sudo ./_dt_files/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
aws --version
