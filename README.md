# DDH Tools | ddt

Tools to install and update DDH.



## Introduction

Base image: ```2022-09-22-raspios-bullseye-armhf.img``` from Lowell Instruments' GDrive.

Do NOT update via GUI or apt.

On RPi3, we need to use the legacy display driver to prevent hang on boot.

```console
$ sudo nano /boot/config.txt
$ # dtoverlay=vc4-fkms-v3d # disable by commenting it
```

Install DWService, or skip this step.

```console
$ cd /home/pi/Downloads
$ wget https://www.dwservice.net/download/dwagent.sh
$ chmod +x /home/pi/Downloads/dwagent.sh
$ sudo ./dwagent.sh
```

Install Nomachine for RPi.

```console
$ cd /home/pi/Downloads
$ wget https://download.nomachine.com/download/8.4/Raspberry/nomachine_8.4.2_1_armhf.deb
$ sudo dpkg -i nomachine_8.4.2_1_armhf.deb
```

Get the DDH Tools repository, a.k.a. ``ddt``:

```console
$ cd /home/pi
$ mkdir li
$ cd li
$ git clone https://github.com/lowellinstruments/ddt.git
$ cd /home/pi/li/ddt
```

Optional. Install Wireguard VPN. Credentials are in our private repository.

```console
$ sudo apt install wireguard
```

## Description of the scripts

Each script has a purpose. They are described next. This list also indicates suggested installation order.

- The ``dt_install_emolt_flag.sh`` script marks this box as eMolt one. In doubt, do NOT run.

- The ``dt_install_linux.sh`` script installs dependencies at the linux level. 
Nothing specific to DDH here yet. 
For example, it copies the ``rc.local`` file from the ``utils`` folder to the
Linux installation and also takes care of the ``juice4halt`` feature.

- The ``dt_install_linux_bluez.sh`` installs bluez v5.6.6 which works better with bleak v0.20.1.

- The ``dt_install_python_venv.sh`` creates a python virtual environment the DDH runs in.

- The ``dt_install_python_liu.sh`` script install the Lowell Instruments' lightweight library LIU in the venv.

- The ``dt_install_python_mat.sh`` script install the Lowell Instruments' library MAT in the venv.

- The ``dt_install_python_ddh.sh`` script updates the software in the DDH folder ``/home/pi/li/ddh``.

- The ``dt_install_python_ddh_moana.sh`` script enables DDH to works with moana loggers. In beta.

- The ``dt_install_python_ddh_settings.py`` python script grabs settings for this DDH box from DDN. In beta.

- The ``dt_install_service_sw_net.sh`` scripts installs and enables a ``systemctl`` service which switches
from cell to wi-fi interfaces to save cellular data.

- The ``dt_install_crontab.sh`` script installs a crontab which monitors the DDH to be run every minute.

- The cell capabilities are installed by doing:

```console
$ sudo ./_dt_files/ppp_install_standalone.sh
```

- The ``dt_install_icons.sh`` script populates the DDH desktop with useful shortcuts. Optional step.



## Post configuration

Some additional useful things to do for better DDH behavior:

- Edit file ```settings/ddh.json``` with boat information.
- Edit file ```settings/_li_all_macs_to_sn.yml``` with the project's MACs.
- Edit file ```run_dds.sh``` with the project's credentials.
- Disable ``xscreensaver``.
- Remove the Bluetooth and software updater icons from the panel.
- Remove any unwanted wi-fi credentials left.
- Replace DWS credentials if they come from a cloned DDH.



## A note about Crontab

In ``_dt_files`` folder, open the ``crontab`` file, do not get confused with ``crontab_ddh.sh``.
The ``crontab`` file contains:

```
* * * * * pi /home/pi/li/ddt/_dt_files/crontab_ddh.sh
```

What does ``crontab_ddh.sh`` do when called? It checks for internet connectivity.
Next, it calls ``dt_update_all_ddh.sh`` to update the DDH software.
Next, runs ``/home/pi/li/ddh/run_dds.sh`` and ``/home/pi/li/ddh/run_ddh.sh``, which run the DDH.
The GUI part is managed by the script ``/home/pi/li/ddh/run_ddh.sh``. 
The BLE part is managed by script ``/home/pi/li/ddh/run_dds.sh``. The latter also contains the AWS credentials.
