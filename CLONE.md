# Cloning Instructions

## Hardware

Grab the first "Raspberry Pi USB to M.2 SATA SSD Converter Board".

Install the SSD disk labeled "DDH golden" on it. This is the source disk of the cloning procedure.

Connect the board to USB.

Grab a second "Raspberry Pi USB to M.2 SATA SSD Converter Board".

Install a destination SSD disk on it. This should be empty, or ok to be erased. This is the destination disk of the cloning procedure.

Connect the board to a different USB port.

    Note:
    Both source and destination SSD disks have to be same size.

Connecting a USB wired keyboard may be useful for the rest of this tutorial.

You can also SSH to the DDH if you are at Lowell Instruments HQ and now the IP of the DDH.


## Software 

Download [balena etcher](https://etcher.balena.io/) program to your computer and run it.

Choose "clone drive" in the first column.

As source or origin, be sure to choose the board containing the "DDH golden" SSD disk.

As destination, be sure to choose the board containing the empty SSD disk.

Press "clone". It will take about 10 minutes.


## Boot the new cloned disk on a DDH

Put the newly cloned destination SSD disk on a DDH. Power on the DDH. Wait a couple of minutes for it to boot.

It could be that the screen remains black on the first boot attempt. This is normal.

Power off the DDH and wait a couple more minutes while it is off.

Power on again the DDH. Now it will boot.


## Updating the new DDH

Since this is cloned disk, it can contain slightly outdated DDH application or settings.

Click the terminal icon on the desktop. Now type:

```console
ddu
```

Choose the option ``DDH update``. This will update the DDH application and API.

If there is one, also choose ``MAT update``. This will update the MAT library.



## DDH Option - remote control with DWService

Please see document README.md for this.




## DDH Option - Power Shield

In case you selected ``sailorhat``, please type the following when ``ddu`` is finished. 

```console
cd /home/pi/li/ddt;
./dt_install_power.sh force
```

When asked, ``enable`` the first option (RTC) and ``skip`` the remaining 3 (CAN, RS485, MAX-M8Q GNSS).



## DDH Option - Cell Shield

The firmware on the cell shield cannot be automated since the boards come from the provider with unknown version.

If the cell shield firmware is from 2017 or 2019, it is outdated. You can check it with:

```console
echo -ne 'AT+CVERSION\r' > /dev/ttyUSB2 && \
cat -v /dev/ttyUSB2
```

No answer? You might have the cell port in ``/dev/ttyUSB4``. 

Re-run the command above replacing '2' with '4'.

Please contact Lowell Instruments if you have an old version. 

We can help you get it updated with our ``ddt_quectel`` tools.




## DDH Option - DDD Dashboard

Ask Lowell Instruments staff to add your DDH to the VPN.

Press the "add new DDH" on the Dashboard main page.




## DDH Option - file settings/config.toml

See this DDH has credentials and monitored MACs.

