# DDH Tools | ddt

## Introduction
This repository contains tools to install the DDH software to a Raspberry, as well as to manage its updates.

## Folder structure

The root folder contains installation scripts. 
Their name ends in `.sh` extension. 
The ``_dt_files`` folder contains support files. 
The ``_wheels`` folder is never to be touched, it just accelerates installations. 
The ``utils`` folder contains complementary utilities which are rarely used.

## Running the scripts
First, we are going to explain the scripts individually. In another section of this document, we will explain one logical order the scripts should be executed. 

These commands should be executed from the folder ``/home/pi/li/ddt`` in the DDH.

Let's start explaining each one of the scripts.
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
$ ./dt_install_python_all_mat_ddh.sh
```
This ``dt_install_python_all_mat_ddh.sh`` script compares the local DDH version versus the one in the github repository. If they match, it ends. Otherwise, it runs the following 2 scripts.
```console
$ ./dt_install_python_mat.sh
```
This script updates the python MAT library in the DDH virtual environment.
```console
$ ./dt_install_python_ddh.sh
```
This script updates the software in the DDH folder ``/home/pi/li/ddh``.

Even if the ``dt_install_python_all_mat_ddh.sh`` determines there is no need to install new software, you can force a reinstall by doing:
```console
$ ./dt_install_python_all_mat_ddh.sh force
```
The ``dt_install_python_venv.sh`` creates a python virtual environment the DDH runs into
```console
$ ./dt_install_python_venv.sh
```
The environment resides in ``/home/pi/li/venv``.

Finally, the script ``dt_install_service_sw_net.sh`` installs and enables a ``systemctl`` service which switches from cell to wifi interfaces to save cellular data.
 
```console
$ ./dt_install_service_sw_net.sh
```

## Important notes
In a Raspberry with nothing installed, a good order or running would be.
```console
$ cd /home/pi/li/ddh/utils
$ ./ppp_install_standalone.sh
```
This gives Raspberry cellullar modem capabilities. After this, the following convert a Raspberry into a DDH.
```console
$ cd /home/pi/li/ddt
$ ./dt_install_linux.sh
$ ./dt_install_python_venv.sh
$ ./dt_install_python_all_mat_ddh.sh
$ ./dt_install_service_sw_net.sh
$ ./dt_install_crontab.sh
```
Please note most of these commands are only supposed to be run once in the life of a DDH. The only  you might need to run more than once in a DDH life is probably ``./dt_install_python_all_mat_ddh.sh`` to update a DDH manually. However, as explained in the following section, the crontab automatically takes care of updates.

## Relation to the DDH software
With the ``ddt`` utilities, we minimize manual interaction with the ``/home/pi/li/ddh`` folder. Also, having a separate folder allows us to update a DDH more easily than updating a folder from itself, like previous versions.

The most important point is the ``crontab``. The new  content is as follows:
```
* * * * * pi /home/pi/li/ddt/_dt_files/crontab_ddh.sh
```
As we can see, we no longer run anything directly within the ``ddh`` folder. Instead, we call ``crontab_ddh.sh`` inside the ``ddt`` folder. 

What does ``crontab_ddh.sh`` do? It checks for internet connectivity, it calls ``dt_install_python_all_mat_ddh.sh`` to update the DDH software and runs the ``/home/pi/li/ddh/run_all.sh`` command. This last one is, finally, the only one which is part of the DDH folder.

The ``/home/pi/li/ddh/run_all.sh`` runs 2 scripts that take care of both parts of a DDH. The GUI part is managed by the script ``/home/pi/li/ddh/run_ddh.sh``. The BLE part is managed by script ``/home/pi/li/ddh/run_dds.sh``. The latter also contains the AWS credentials.


