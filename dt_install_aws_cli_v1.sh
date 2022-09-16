#!/usr/bin/env bash


LI=/home/pi/li
DDT=$LI/ddh_tools


# abort upon any error
clear && echo && set -e
trap 'echo ‘$BASH_COMMAND’ TRAPPED! rv $?' EXIT


# download it
echo; echo 'I > download AWS cli v1'
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip


# you may need to change first line of awscli-bundle/install
# you may need to install python3-venv


# install it
echo; echo 'I > install AWS cli v1'
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
aws --version
