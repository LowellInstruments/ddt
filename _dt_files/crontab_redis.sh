!/usr/bin/env bash
clear



echo "is redis already running?"
systemctl is-active redis
rv=$?
if [ $rv -eq 0 ]; then
    echo "redis systemctl already running"
    exit 1
fi


redis-cli ping
rv=$?
if [ $rv -eq 0 ]; then
    echo "redis process already running"
    exit 1
fi



echo "starting crontab_redis"
mkdir /li/redis
sudo chown -R redis:redis /li/redis
cd /li/redis
redis-server --dir /li/redis &
