# DDH Tools | ddt

Tools to set up a Rpi as a DDH. Don't manually run ```apt```. We take care of all.


## Remote access

If you followed the steps in document ``BASE_LINUX.md``, your Rpi is in your wi-fi and can SSH to it.

You can install an additional remote control tool called DWService, by opening a terminal and doing:

```
cd /home/pi/Downloads;
wget https://www.dwservice.net/download/dwagent.sh;
chmod +x /home/pi/Downloads/dwagent.sh;
sudo /home/pi/Downloads/dwagent.sh;
```

## Different Raspberry versions

To know the architecture of your raspberrypi OS, just run ``arch`` in the terminal. ``armv7l`` indicates 32-bits and ``aarch64`` indicates 64-bits.

Rpi3 can run on 32-bits kernel, [release 2023-05-03](https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-2023-05-03/2023-05-03-raspios-bullseye-armhf.img.xz).

Rpi4 can run on 32-bits kernel, [release 2023-05-03](https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-2023-05-03/2023-05-03-raspios-bullseye-armhf.img.xz).

Rpi4 can also run on 64-bits kernel, [release 2024-03-15](https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-2024-03-15/2024-03-15-raspios-bookworm-armhf.img.xz) but this has not been tested in dept.

32-bits kernel uses ```/boot/config.txt```. 64-bits kernel uses ```/boot/firmware/config.txt```.

ONLY IN CASE the DDH hangs during boot on a black screen, it might be because of 7-inch display driver. 

On a laptop, or via SSH, open the SSD disk with a USB reader and do the following:

```console
sudo nano /<proper_path>/config.txt
    # dtoverlay=vc4-kms-v3d # ---> comment this line to use old legacy video driver
```

Additionally, in case of Rpi4 64-bits, the touch screen fails because of Wayland. Set X11 with option ```A6``` in:

```console
sudo raspi-config
```


## Turning a raspberry into a DDH

``Step 1)`` download the DDH installer from the DDH Tools, or ``ddt`` repository. For this, you can copy-n-paste the following instructions.

```console
cd /home/pi;
mkdir li;
cd li;
git clone --branch toml https://github.com/lowellinstruments/ddt.git;
cd /home/pi/li/ddt;
```

``Step 2) You should be in ``/home/pi/li/ddt`` at this point. Now, run the installer.

```console
./dt_install_all.sh
```` 

The previous command will take about 15 minutes. Now reboot the DDH with:

```console
reboot
```` 

## Cell shield firmware update

If the cell shield firmware is from 2017 or 2019, it is outdated. You can check it with:

```console
echo -ne 'AT+CVERSION\r' > /dev/ttyUSB2 && \
cat -v /dev/ttyUSB2
```

Please contact Lowell Instruments so we can help you get it updated with our ``ddt_quectel`` tools.


## Post configuration

Some additional useful things to do for better DDH behavior:

- ``Click menu / Preferences / Screen Saver``. Next to "mode", you can disable it. Use a mouse in case the drop-down does not open properly.
- Remove the Bluetooth and software updater icons from the upper panel. Right-click on them.
- ``Click menu / Preferences / mouse and keyboard settings / 500`` to slo down the requirements to double-click. 
- Ensure ``juice4halt`` is running by checking existence of file:
- You can now run the ``ddc`` tool to configure your DDH behavior.
