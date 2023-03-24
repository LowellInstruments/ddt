# DDH Tools | ddt



## Introduction

Tools to install and update DDH.

Base image: ```2022-09-22-raspios-bullseye-armhf.img``` from Lowell Instruments' GDrive.

On RPi3, we need to use the legacy display driver to prevent hang on boot.

```console
$ sudo nano /boot/config.txt
$ # dtoverlay=vc4-fkms-v3d # disable by commenting it
```

Do NOT update via GUI or apt.

Install DWService.

```console
$ cd /home/pi/Downloads
$ wget https://www.dwservice.net/download/dwagent.sh
$ chmod +x /home/pi/Downloads/dwagent.sh
$ sudo ./dwagent.sh
```



## Description of the scripts

Each script has a function and they are described next.


- The ``dt_install_emolt_flag.sh`` script marks this box as eMolt one. In doubt, do not run.

- The ``dt_install_crontab.sh`` script installs a crontab which monitors the DDH to be run every minute.

- The ``dt_install_linux.sh`` script installs dependencies at the linux level. 
Nothing specific to DDH here yet. 
For example, it copies the ``rc.local`` file from the ``utils`` folder to the
Linux installation and also takes care of the ``juice4halt`` feature.

- The ``dt_install_linux_bluez.sh`` installs bluez==5.6.6 which works better with bleak.

- The ``dt_install_python_venv.sh`` creates a python virtual environment the DDH runs in.

- The ``dt_install_liu.sh`` script install the Lowell Instruments' lightweight library liu.

- The ``dt_install_python_mat.sh`` script updates python MAT library in the virtual environment.

- The ``dt_install_python_ddh.sh`` script updates the software in the DDH folder ``/home/pi/li/ddh``.

- The ``dt_install_python_ddh_moana.sh`` script enables DDH to works with moana loggers.

- The ``dt_install_python_ddh_settings.sh`` script grabs settings for this DDH box from DDN.

- The ``dt_install_icons.sh`` script populates the DDH desktop with useful shortcuts.

- The ``dt_install_service_sw_net.sh`` scripts installs and enables a ``systemctl`` service which switches
from cell to wi-fi interfaces to save cellular data.

 

## Installation

In a Raspberry with nothing installed, do the following:

```console
$ cd /home/pi; mkdir li; cd li
$ git clone https://github.com/lowellinstruments/ddt.git
$ cd /home/pi/li/ddt

(only on emolt_ddh boxes) -> $ ./dt_install_emolt_flag.sh

$ ./dt_install_linux.sh
$ ./dt_install_linux_bluez.sh
$ ./dt_install_python_venv.sh
$ ./dt_install_python_liu.sh
$ ./dt_install_python_mat.sh
$ ./dt_install_python_ddh.sh
$ ./dt_install_python_ddh_moana.sh
$ ./dt_install_python_ddh_settings.sh <box_SN> <ddh.json/run_dds.sh>
$ ./dt_install_service_sw_net.sh
$ ./dt_install_crontab.sh
$ sudo ./_dt_files/ppp_install_standalone.sh

( maybe yes, maybe not) -> $ ./dt_install_icons.sh

(custom edit the ddh.json file with boat information)
(custom edit the settings/_li_all_macs_to_sn.yml file with MACs)
(custom edit the run_dds.sh file with AWS credentials)
```



## Post configuration

Some additional useful things to do for better DDH behavior:

- Disable ``xscreensaver``.
- Remove the Bluetooth and software updater icons from the panel.
- Remove any unwanted wi-fi credentials left.
- Update DWS credentials if they were cloned.



## Crontab

In ``_dt_files`` folder, open the ``crontab`` file, do not get confused with ``crontab_ddh.sh``.
The ``crontab`` file contains:

```
* * * * * pi /home/pi/li/ddt/_dt_files/crontab_ddh.sh
```

What does ``crontab_ddh.sh`` do when called? It checks for internet connectivity.
Next, it calls ``dt_install_python_all_mat_ddh.sh`` to update the DDH software.
Next, runs the ``/home/pi/li/ddh/run_all.sh`` command, which launches both software parts of a DDH.
The GUI part is managed by the script ``/home/pi/li/ddh/run_ddh.sh``. 
The BLE part is managed by script ``/home/pi/li/ddh/run_dds.sh``. The latter also contains the AWS credentials.


