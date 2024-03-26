# DDH Tools | ddt

Tools to install DDH. Don't manually run ```apt```. We take care of all.


## Different Raspberry versions

DDH based on Rpi3 runs on 32-bits kernel, raspberryOS release 2023-12-05. 

DDH based on Rpi4 runs on 64-bits kernel, raspberryOS release 2024-03-15. 

Rpi3 uses /boot/config.txt. Rpi4 uses /boot/firmware/config.txt.

During the first boot, it might hang at boot on a black screen because of our 7-inch display.

On a laptop, or via SSH, open the SSD disk with a USB reader and do the following:

```console
sudo nano /<proper_path>/config.txt
    # dtoverlay=vc4-kms-v3d # ---> comment this line to use old legacy video driver
```

On Rpi4, the touch screen fails because of Wayland. To use X11 use option A6 in:

```console
sudo raspi-config
```


## Remote access

Join your DDH to your wi-fi. Next, use a keyboard and go to terminal and type:

```console
ifconfig -a    
```

Annotate the IP address for the wlan0 interface. 

Run any SSH client software to such IP.

Enter credentials "user" and "password" as per document BASE_LINUX.md.

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

Copy-n-paste the following to get the DDH Tools ``ddt``.

```console

```

## Turning a raspberry into a DDH

You just need to run ``./dt_install_all.sh``. 

Any further installation tweak can be done at a later time running ``ddi``.


## Cell shield firmware update

Old cell shield firmware may be from 2017 or 2019.

```console
minicom -D /dev/ttyUSB2 -b 115200
AT+CVERSION
```

For a year < 2022 in the answer, contact Lowell Instruments and we will upgrade it.


## Post configuration

Some additional useful things to do for better DDH behavior:

- Edit file ```settings/config.toml``` with project's settings and credentials.
- Go to Rpi menu, click "Preferences" and "Screen Saver". Disable it.
- Remove the Bluetooth and software updater icons from the upper panel. Right-click on them.
- Ensure ``juice4halt`` is running by checking existence of file:

``` console
ls /home/pi/li/juice4halt/bin/j4h_halt_flag
```

- Remember to edit the crontab with:

``` console
sudo nano /etc/crontab
```
  
Run the DDH software by clicking the icon on the desktop, or wait for the crontab to do it for you.
