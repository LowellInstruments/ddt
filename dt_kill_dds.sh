#!/usr/bin/env bash


echo; echo 'K > killing DDS'
pkill -F /tmp/dds.pid || true
