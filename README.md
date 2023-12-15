# DDH Tools | ddt

Tools to install and update DDH.

## Introduction

To clone a disk, first follow the steps in BASE_LINUX.md document.

NEVER update any Linux part via GUI or apt. We take care of this.

## In case of Raspberry Pi 3

On a RPi3, which you can check by ```$ cat /proc/cpuinfo```, do the following:

```console
sudo nano /boot/config.txt
    # dtoverlay=vc4-fkms-v3d # ---> comment this line so it uses the old legacy video driver
```

## Remote access

Drag your finger from the middle of the screen up to the wi-fi icon at the top-right part of the DDH.

Lift your finger up to get a pop-up telling the assigned IP address. It will be something 
like "192.x.x.x" or "10.x.x.x". Ignore any addresses starting with "169.".

Run any SSH client software and go to such IP. Enter credentials "user" and "password" as 
set in BASE_LINUX.md document.

---
Optional. Install DWService. Just copy-paste the following instructions.

```console
cd /home/pi/Downloads;
wget https://www.dwservice.net/download/dwagent.sh;
chmod +x /home/pi/Downloads/dwagent.sh;
sudo /home/pi/Downloads/dwagent.sh;
```
---

Get the DDH Tools repository, a.k.a. ``ddt``. Feel free to copy and paste the following.

```console
cd /home/pi;
mkdir li;
cd li;
git clone https://github.com/lowellinstruments/ddt.git;
cd /home/pi/li/ddt;
```

## Description of the DDT scripts

List all the scripts within the ```ddt``` folder by entering:

```console
cd /home/pi/li/ddt;
ls;
```

The list of DDT scripts, in suggested order, comes next:

- The ``./dt_install_custom_box.sh`` script customizes boxes with features such as eMolt or grouped AWS S3.

- The ``./dt_install_linux.sh`` script installs linux dependencies. Also takes care of custom ``rc.local``
and features such as ``juice4halt``.

- The ``./dt_install_linux_bluez.sh`` installs bluez v5.66, which works better with bleak v0.20.x.

- The ``./dt_install_python_ddh.sh`` is a GUI installer that updates the DDH software in folder ``/home/pi/li/ddh``.

- The ``./dt_install_crontab.sh`` script installs a crontab that runs and monitors the DDH.

- The ``./dt_install_icons.sh`` script populates the DDH desktop with useful shortcuts.

- The ``./dt_install_alias.sh`` script installs ``ddc`` and ``ddi`` utilities.

- Optional. Only if you have cell modem capabilities. 
The shield option is number "6: 3G/4G hat", the port is "ttyUSB3" and common APN names vary by SIM type.

```console
sudo ./_dt_files/ppp_install_standalone.sh
```

- Optional. Only if you have cell modem capabilities. The ``./dt_install_service_sw_net.sh`` scripts 
sets a ``systemctl`` service which switches from cell to wi-fi to save data charges.


## Cell shield firmware update

Old cell shield firmware may be from 2017 or 2019.

```console
minicom -D /dev/ttyUSB2 -b 115200
AT+CVERSION
```

---

Optional. Only to be done by Lowell Instruments. 
If you need to update cell shield firmware version for ```EG25 modules``` (not EC25) just do:

```console
cd /home/pi/Downloads;
git clone https://github.com/lowellinstruments/ddt_quectel.git;
cd ddt_quectel;
unzip QFirehose_Linux_Android_V1.4.13.zip;
unzip EG25GGBR07A08M2G_30.007.30.007.zip;
cd QFirehose_Linux_Android_V1.4.13;
make;
sudo ./QFirehose -f ..
```

---

Optional. Only to be done by Lowell Instruments. Instead, for ```EC25 modules``` do:

```console
cd /home/pi/Downloads;
git clone https://github.com/lowellinstruments/ddt_quectel.git;
cd ddt_quectel;
unzip QFirehose_Linux_Android_V1.4.13.zip;
unzip EC25AFAR05A07M4G_30.003.30.003.zip;
cd QFirehose_Linux_Android_V1.4.13;
make;
sudo ./QFirehose -f ..
```
---


## Post configuration

Some additional useful things to do for better DDH behavior:

- Edit file ```settings/config.toml``` with the project's credentials. Lowell Instruments will do this for you.
- Disable ``xscreensaver``. Go to Rpi menu, click "Preferences" and "Screen Saver". Disable it.
- Remove the Bluetooth and software updater icons from the panel.
- Remove any unwanted wi-fi credentials left.
- Replace DWS credentials if they come from a cloned DDH.
- Ensure ``juice4halt`` is running by checking existence of file:

``` console
ls /home/pi/li/juice4halt/bin/j4h_halt_flag
```
  
Finally, run the DDH software once by clicking the icon on the desktop.
