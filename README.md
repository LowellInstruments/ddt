# DDH Tools | ddt

Tools to install DDH. Don't manually run ```apt-get update```. We take care of all.


## In case of Raspberry Pi 3

On a RPi3, which you can check by ```$ cat /proc/cpuinfo```, do the following:

```console
sudo nano /boot/config.txt
    # dtoverlay=vc4-fkms-v3d # ---> comment line to force old video driver
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

Copy-n-paste the following to obtain the DDH Tools repository ``ddt``.

```console
cd /home/pi;
mkdir li;
cd li;
git clone --branch toml https://github.com/lowellinstruments/ddt.git;
cd /home/pi/li/ddt;
```

## Turning a raspberry into a DDH

You just need to run ``./dt_install_all.sh``. 

Any further installation tweak can be done running ``ddi``.


## Cell shield firmware update

Old cell shield firmware may be from 2017 or 2019.

```console
minicom -D /dev/ttyUSB2 -b 115200
AT+CVERSION
```

If you see a year < 2022 in your answer, contact Lowell Instruments and we will do this for you.


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

- Use the icons in the desktop to test your DDH installation.
- Remember to edit the crontab with:

``` console
sudo nano /etc/crontab
```
  
Run the DDH software by clicking the icon on the desktop, or wait for the crontab to do it for you.
