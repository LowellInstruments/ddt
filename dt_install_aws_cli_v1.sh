#!/usr/bin/env bash


# you may need to install python3-venv


# abort upon any error
clear && echo && set -e
trap 'echo ‘$BASH_COMMAND’ TRAPPED! rv $?' EXIT


# unzip our file inside _dt_files in folder ddt
cd _dt_files && unzip awscli-bundle.zip


# install it
echo; echo 'I > install AWS cli v1'
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
aws --version
