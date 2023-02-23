# DDH Tools | ddt

## Introduction


This repository contains tools to install and update the DDH software.

The base image is ```2022-09-22-raspios-bullseye-armhf.img``` and is in our GDrive.

Flash it and do NOT update ```apt-get upgrade```. We take care of this in our scripts.

---

Remember: Download and install DWService.


## Folder structure


The root folder contains installation scripts whose names end in `.sh` extension. 
The ``_dt_files`` folder contains support files. 
The ``utils`` folder contains complementary utilities which are rarely used.


## Running the scripts


These commands should be executed from the folder ``/home/pi/li/ddt`` in the DDH.


```console
$ ./dt_install_emolt_flag.sh
```


The ``dt_install_emolt_flag.sh`` script marks this box to be treated as eMolt one. In doubt, do not run.


```console
$ ./dt_install_crontab.sh
```


The ``dt_install_crontab.sh`` script installs a crontab which monitors the DDH to be run every minute.


```console
$ ./dt_install_linux.sh
```


The ``dt_install_linux.sh`` script installs dependencies at the linux level. 
Nothing specific to DDH here yet. 
For example, it copies the ``rc.local`` file from the ``utils`` folder to the
Linux installation and also takes care of the ``juice4halt`` feature.



```console
$ ./dt_install_linux_bluez.sh
```


Bleak on Raspberry is picky. For version bleak==0.19.5, seems bluez==5.6.6 works fine.



```console
$ ./dt_install_liu.sh
```


The ``dt_install_liu.sh`` script install the lightweight library liu.


```console
$ ./dt_install_python_all_mat_ddh.sh
```

This ``dt_install_python_all_mat_ddh.sh`` script compares the local DDH version versus the one in the github repository. 
If they match, it ends. Otherwise, it runs the following 2 scripts.


```console
$ ./dt_install_python_mat.sh
```


This script updates the python MAT library in the DDH virtual environment.


```console
$ ./dt_install_python_ddh.sh
```


This script updates the software in the DDH folder ``/home/pi/li/ddh``.

You can FORCE a reinstall by doing:


```console
$ ./dt_install_python_all_mat_ddh.sh force
```


The ``dt_install_python_venv.sh`` creates a python virtual environment the DDH runs in.


```console
$ ./dt_install_python_venv.sh
```


The environment resides in ``/home/pi/li/venv``.


```console
$ ./dt_install_icons.sh
```

The ``dt_install_icons.sh`` populates the DDH desktop with useful shortcuts.


Finally, the script ``dt_install_service_sw_net.sh`` installs and enables a ``systemctl`` service which switches
from cell to wifi interfaces to save cellular data.

 
```console
$ ./dt_install_service_sw_net.sh
```


## Important notes

In a Raspberry with nothing installed, a good order or running would be:


```console
$ cd /home/pi/li/ddt

(only on emolt_ddh boxes) -> $ ./dt_install_emolt_flag.sh

$ ./dt_install_linux.sh
$ ./dt_install_linux_bluez.sh
$ ./dt_install_python_venv.sh
$ ./dt_install_python_liu.sh
$ ./dt_install_python_all_mat_ddh.sh
$ ./dt_install_service_sw_net.sh
$ ./dt_install_crontab.sh
$ ./dt_install_icons.sh
$ ./_dt_files/ppp_install_standalone.sh

(custom edit the ddh.json file with boat information)
(custom edit the run_dds.sh file with AWS credentials)
```

Please note most of these commands are only supposed to be run once in the life of a DDH. 
You might need to run more often is ``./dt_install_python_all_mat_ddh.sh`` to update a DDH manually. 
However, as explained in the following section, the crontab automatically takes care of updates.

---

Remember: disable the screensaver, remove the Bluetooth and software update icons from the panel.



## Crontab


An important point is the ``crontab`` file, do not get confused with ``crontab_ddh.sh``. The former contains:


```
* * * * * pi /home/pi/li/ddt/_dt_files/crontab_ddh.sh
```


What does ``crontab_ddh.sh`` do? It checks for internet connectivity.
Next, it calls ``dt_install_python_all_mat_ddh.sh`` to update the DDH software.
Next, runs the ``/home/pi/li/ddh/run_all.sh`` command, which launches both software parts of a DDH.
The GUI part is managed by the script ``/home/pi/li/ddh/run_ddh.sh``. 
The BLE part is managed by script ``/home/pi/li/ddh/run_dds.sh``. The latter also contains the AWS credentials.


