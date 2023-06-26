# DDH Tools | ddt

Tools to install and update DDH.



## Introduction

Base image: ```2022-09-22-raspios-bullseye-armhf.img``` from Lowell Instruments' GDrive.

Do NOT update via GUI or apt.

Check the cell shield firmware version.

On RPi3, we need to use the legacy display driver to prevent hang on boot.

```console
$ sudo nano /boot/config.txt
$ # dtoverlay=vc4-fkms-v3d # disable by commenting it
```

Install DWService, or skip this step.

```console
cd /home/pi/Downloads;
wget https://www.dwservice.net/download/dwagent.sh;
chmod +x /home/pi/Downloads/dwagent.sh;
sudo /home/pi/Downloads/dwagent.sh;
```

Optional. Install Nomachine for RPi.

```console
$ cd /home/pi/Downloads
$ wget https://download.nomachine.com/download/8.4/Raspberry/nomachine_8.4.2_1_armhf.deb
$ sudo dpkg -i nomachine_8.4.2_1_armhf.deb
```


Optional. Install Wireguard VPN. Credentials are in our private repository.

```console
$ sudo apt install wireguard
```

Get the DDH Tools repository, a.k.a. ``ddt``:

```console
cd /home/pi;
mkdir li;
cd li;
git clone https://github.com/lowellinstruments/ddt.git;
cd /home/pi/li/ddt;
```

## Description of the scripts

The next list explains the purpose of each script as well as indicates suggested installation order.

- The ``./dt_install_emolt_flag.sh`` script marks this box as eMolt one. Do NOT run in case of doubt.

- The ``./dt_install_linux.sh`` script installs linux dependencies, nothing specific to DDH here yet. 
For example, it copies the ``rc.local`` file from the ``utils`` folder to the
Linux installation and takes care of the ``juice4halt`` feature.

- The ``./dt_install_linux_bluez.sh`` installs bluez v5.66, which works better with bleak v0.20.x.

- The ``./dt_install_python_ddh.sh`` script updates the DDH software in folder ``/home/pi/li/ddh``.

- The ``./dt_install_python_ddh_settings.py`` script grabs settings for this DDH box from DDN. In beta.

- The ``./dt_install_service_sw_net.sh`` scripts installs and enables a ``systemctl`` service which switches
from cell to wi-fi interfaces to save cellular data.

- The ``./dt_install_crontab.sh`` script installs a crontab that runs and monitors the DDH.

- The cell capabilities are installed by doing:

```console
$ sudo ./_dt_files/ppp_install_standalone.sh
```

- The ``./dt_install_icons.sh`` script populates the DDH desktop with useful shortcuts. Optional.



## Post configuration

Some additional useful things to do for better DDH behavior:

- Edit file ```settings/ddh.json``` with boat information.
- Edit file ```settings/_li_all_macs_to_sn.yml``` with the project's MACs.
- Edit file ```run_dds.sh``` with the project's credentials.
- Disable ``xscreensaver``.
- Remove the Bluetooth and software updater icons from the panel.
- Remove any unwanted wi-fi credentials left.
- Replace DWS credentials if they come from a cloned DDH.
