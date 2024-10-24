#!/usr/bin/python3
# title           :shutdown_script.py
# description     :This script runs on Raspberry Pi equipped with the Juice4Halt module.
# author          : Greg <gosmondson@gmail.com>
# date            :20160504
# version         :1.0
# usage		 :copy this file to /home/pi/li/juice4halt/bin/
#   and make it executable: sudo chmod 755 shutdown_script.py
#   then add it to rc.local: /home/pi/li/juice4halt/bin/shutdown_script.py &
# notes           :www.juice4halt.com
# copyright	 :GNU GPL v3.0
# ==============================================================================

import RPi.GPIO as GPIO
import time
import os


print("Starting up j4h interface")
GPIO.setmode(GPIO.BCM)
GPIO.setup(25, GPIO.OUT)
GPIO.output(25, GPIO.LOW)
time.sleep(.1)
GPIO.output(25, GPIO.HIGH)


print("Interface complete")
GPIO.setup(25, GPIO.IN)
time.sleep(.1)

print("Waiting for power to go away")
pinval = 1
while pinval == 1:
    pinval = GPIO.input(25)
    time.sleep(.2)

print("power lost")
GPIO.setup(25, GPIO.OUT)
GPIO.output(25, GPIO.LOW)
os.system("/home/pi/li/juice4halt/bin/popup_j4h.sh &")
os.system("rm -f /home/pi/li/juice4halt/bin/j4h_halt_flag")
os.system("touch /home/pi/li/juice4halt/bin/j4h_halt_flag")
time.sleep(2)
os.system("sudo halt")
