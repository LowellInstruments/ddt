# DDH Tools | ddt

Tools to convert a Rpi into a DDH. Don't manually run ```apt```. We take care of all.


## Remote access

If you followed the steps in document BASE_LINUX.md your Rpi is in your wi-fi and can SSH to it.

We will install another remote control tool, DWService, later.


## Different Raspberry versions

To know the architecture of your raspberrypi OS, just run ``arch`` in the terminal. ``armv7l`` indicates 32-bits and ``aarch64`` indicates 64-bits.

Rpi3 can run on 32-bits kernel, [release 2023-05-03](https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-2023-05-03/2023-05-03-raspios-bullseye-armhf.img.xz).

Rpi4 can run on 32-bits kernel, [release 2023-05-03](https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-2023-05-03/2023-05-03-raspios-bullseye-armhf.img.xz).

Rpi4 can also run on 64-bits kernel, [release 2024-03-15](https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-2024-03-15/2024-03-15-raspios-bookworm-armhf.img.xz) but this has not been tested in dept.

32-bits kernel uses ```/boot/config.txt```. 64-bits kernel uses ```/boot/firmware/config.txt```.

ONLY IN CASE it hangs during boot on a black screen, it might be because of 7-inch display driver. 

On a laptop, or via SSH, open the SSD disk with a USB reader and do the following:

```console
sudo nano /<proper_path>/config.txt
    # dtoverlay=vc4-kms-v3d # ---> comment this line to use old legacy video driver
```

On Rpi4 on 64-bits, the touch screen fails because of Wayland. Set X11 with option ```A6``` in:

```console
sudo raspi-config
```


## Getting the DDH installation tools

This is the first step of converting a Rpi into a DDH.

Copy-n-paste the following to get the DDH Tools ``ddt``. This can be considered the DDH installer.

```console
cd /home/pi;
mkdir li;
cd li;
git clone --branch toml https://github.com/lowellinstruments/ddt.git;
cd /home/pi/li/ddt;
```

## Turning a raspberry into a DDH

The installer will end up and leave you in the proper directory, which is ```/home/pi/li/ddt```.

You just need to run ``./dt_install_all.sh``. 

Any further installation tweak can be done at a later time running ``ddi``.


## Cell shield firmware update

Old cell shield firmware may be from 2017 or 2019.

```console
minicom -D /dev/ttyUSB2 -b 115200
AT+CVERSION
```

For a year < 2022 in the answer, contact Lowell Instruments. 

We will upgrade it using our ```ddt_quectel``` tools.


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
