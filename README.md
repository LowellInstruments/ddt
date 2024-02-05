# DDH Tools | ddt

Tools to install and update DDH. No need to ```apt-get update```. We take care of this.


## In case of Raspberry Pi 3

On a RPi3, which you can check by ```$ cat /proc/cpuinfo```, do the following:

```console
sudo nano /boot/config.txt
    # dtoverlay=vc4-fkms-v3d # ---> comment this line so it uses the old legacy video driver
```

## Remote access

Join your DDH to your wi-fi network. Next, go to terminal and type:

```console
ifconfig -a    
```

Annotate the IP address indicated in the wlan0 interface. 
Run any SSH client software and go to such IP. 
Enter credentials "user" and "password" as set in BASE_LINUX.md document.

---
Optional. Install DWService. Just copy-paste the following instructions.

```console
cd /home/pi/Downloads;
wget https://www.dwservice.net/download/dwagent.sh;
chmod +x /home/pi/Downloads/dwagent.sh;
sudo /home/pi/Downloads/dwagent.sh;
```
---


## Getting the installation tools

Get the DDH Tools repository, a.k.a. ``ddt``. Feel free to copy and paste the following.

```console
cd /home/pi;
mkdir li;
cd li;
git clone https://github.com/lowellinstruments/ddt.git;
cd /home/pi/li/ddt;
```

## Turning a raspberry into a DDH

You only need to run ``./dt_install_all.sh``. 


## Cell shield firmware update

Old cell shield firmware may be from 2017 or 2019.

```console
minicom -D /dev/ttyUSB2 -b 115200
AT+CVERSION
```

If you see a year < 2022 in your answer, please contact Lowell Instruments and we will do this for you.


## Post configuration

Some additional useful things to do for better DDH behavior:

- Edit file ```settings/config.toml``` with the project's credentials.
- Disable ``xscreensaver``. Go to Rpi menu, click "Preferences" and "Screen Saver". Disable it.
- Remove the Bluetooth and software updater icons from the panel.
- Remove any unwanted wi-fi credentials left.
- Replace DWS credentials if they come from a cloned DDH.
- Ensure ``juice4halt`` is running by checking existence of file:

``` console
ls /home/pi/li/juice4halt/bin/j4h_halt_flag
```
  
Finally, run the DDH software once by clicking the icon on the desktop.
