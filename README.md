# DDH Tools | ddt

Tools to install and update DDH.

## Introduction

First, follow the steps in BASE_LINUX.md document.

Remember to NEVER update any Linux part via GUI or apt. We will take care of this.

If you have a RPi3, which you can check by ```$ cat /proc/cpuinfo```, do the following steps.

```console
sudo nano /boot/config.txt
    # dtoverlay=vc4-fkms-v3d # ---> comment this line so it uses the old legacy video driver
```

## Remote access: SSH and GUI

Drag your finger from the middle of the screen up to the wi-fi icon at the top-right part of the DDH.

Lift your finger up and a pop-up telling the assigned IP address. Run any SSH client software and go to such IP.

Probably, your DDH IP address will be something like "192.x.x.x" or "10.x.x.x". Ignore any addresses starting with "169.".

Enter credentials "user" and "password" as set in BASE_LINUX.md document. You are now in a DDH terminal.

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

The following list overviews each script as well as indicates a suggested installation order.

- The ``./dt_install_custom_box.sh`` script customizes boxes with features such as eMolt or grouped AWS S3.

- The ``./dt_install_linux.sh`` script installs linux dependencies, nothing specific to DDH here yet. 
For example, it automatically copies the ``rc.local`` file from the ``utils`` folder to the
Linux installation and takes care of the ``juice4halt`` feature.

- The ``./dt_install_linux_bluez.sh`` installs bluez v5.66, which works better with bleak v0.20.x.

- The ``./dt_install_python_ddh.sh`` is a GUI that updates the DDH software in folder ``/home/pi/li/ddh``.

- Optional. The ``./dt_install_python_ddh_settings.py`` script grabs settings for this DDH box from DDN. In beta. Skip.

- Optional. Run the next command only if you have cell modem capabilities. The shield option is number "6: 3G/4G hat", the port is "ttyUSB3" and common APN names vary by SIM type. The cell features are installed by doing:

```console
sudo ./_dt_files/ppp_install_standalone.sh
```

- Optional. Again, run the next command only if you have cell modem capabilities. The ``./dt_install_service_sw_net.sh`` scripts sets a ``systemctl`` service which switches
from cell to wi-fi interfaces to save cell data.

- The ``./dt_install_crontab.sh`` script installs a crontab that runs and monitors the DDH.

- The ``./dt_install_icons.sh`` script populates the DDH desktop with useful shortcuts.

- The ``./dt_install_alias.sh`` script installs ``ddc`` and ``ddi`` utilities.

## Cell shield firmware update

Optional. Just skip this. Lowell Instruments will do it for you upon request. Old firmware may be from 2017 or 2019.

```console
minicom -D /dev/ttyUSB2 -b 115200
AT+CVERSION
```

---
Optional. If you need to update cell shield firmware version for ```EG25 modules``` (not EC25) just do:

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
Optional. Instead, for ```EC25 modules``` do:

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

- Edit file ```settings/_li_all_macs_to_sn.yml``` with the project's MACs.
- Edit file ```run_dds.sh``` with the project's credentials. Lowell Instruments will do this for you.
- Edit file ``settings/ddh.json`` by opening the "Setup" tab on DDH and add your loggers' macs.
- Disable ``xscreensaver``. Go to Rpi menu, click "Preferences" and "Screen Saver". Disable it.
- Remove the Bluetooth and software updater icons from the panel.
- Remove any unwanted wi-fi credentials left.
- Replace DWS credentials if they come from a cloned DDH.
- Ensure ``juice4halt`` is running by checking existence of file:

``` console
ls /home/pi/li/juice4halt/bin/j4h_halt_flag
```
  
Finally, run the DDH software once by clicking the icon on the desktop.

- In beta, you can also simplify some of these tasks by running ``ddc`` or ``ddu``.
