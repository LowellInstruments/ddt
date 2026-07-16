#!/usr/bin/env bash



clear
echo



N_A=$(lsblk | grep sda | wc -l)
R_A=$?


# ensure we have SOMETHING on /dev/sda
if [ $R_A -ne 0 ]; then
        echo "ERROR! NOTHING detected on /dev/sda"
        read
        exit 1
fi



# we do, ensure this SOMETHINGS is NOT a disk
lsblk | grep sda | grep "119.2G" > /dev/null
if [ $? -eq 0 ]; then
        echo "ERROR! DISK detected on /dev/sda, BUT we want a card"
        read
        exit 1
fi



# ask again
read -p "This will erase your card on /dev/sda, proceed? (y/n): " yn
case $yn in
    [Yy]* ) echo "Proceeding..."; ;;
    [Nn]* ) echo "Exiting..."; exit;;
    * ) echo "Please answer yes or no.";;
esac



# we are PRETTY safe here
echo "copying IMAGE file to SD card on /dev/sda..."
sudo dd if=$HOME/Desktop/sd.img of=/dev/sda bs=4M status=progress
rv=$?
if [ $rv -eq 0 ]; then
        echo "image cloning to SD card OK!"
else
        echo "ERROR cloning image to SD card"
fi

echo "press return to finish"
read


