# DDH Tools | ddt

Tools to set up a Rpi as a DDH. Don't manually run ```apt```. We take care of all.


## Different Raspberry Pi hardware versions

Read about them in document PI_HARDWARE.md.


## Remote access

If you followed the steps in document ``BASE_LINUX.md``, your Rpi is in your wi-fi and can SSH to it.

You can install an additional remote control tool called DWService, by opening a terminal and doing:

```
cd /home/pi/Downloads;
wget https://www.dwservice.net/download/dwagent.sh;
chmod +x /home/pi/Downloads/dwagent.sh;
sudo /home/pi/Downloads/dwagent.sh;
```

If DWS complains about Wayland, switch to X11 with option ```6 / A6``` in:

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

``Step 2)`` You should be in ``/home/pi/li/ddt`` at this point. Run the installer with:

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

No answer? You might have the cell port in ``/dev/ttyUSB4``. Re-run the command above replacing '2' with '4'.

Please contact Lowell Instruments if you have an old version. 

We can help you get it updated with our ``ddt_quectel`` tools.


## Post configuration

Some additional useful things to do for better DDH behavior:

- ``Click menu / Preferences / Screen Saver``. Next to "mode", you can disable it. Use a mouse in case the drop-down does not open properly.
- Remove the Bluetooth and software updater icons from the upper panel. To do this, right-click on them.
- ``Click menu / Preferences / mouse and keyboard settings / 500`` to slo down the requirements to double-click.
- ``Click menu / Preferences > Raspberry Pi Configuration > Localisation > Timezone`` to set your timezone.
- Run the ``ddc`` tool to make sure all the configuration is OK.

In case a DDH seems to get stuck on boot with a black screen, open file ``/boot/config.txt`` and comment:

```console
#dtoverlay=vc4-kms-v3d
```
