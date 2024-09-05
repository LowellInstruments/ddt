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


## Booting the newly cloned disk on a DDH

Put the newly cloned destination SSD disk on a DDH. Power on the DDH. Wait a couple of minutes for it to boot.

It could be that the screen remains black on the first boot attempt. This is normal.

Power off the DDH and wait a couple more minutes while it is off.

Power on again the DDH. Now it will boot.


## Install DWService

Create a new agent in your DWService account for this DDH. Next, open a terminal and paste:

```console
cd /home/pi/Downloads;
chmod +x dwagent.sh;
sudo ./dwagent.sh install
```

Select "Install" and accept the default options.
Login to Dwservice with the accounbt you want to use for the DDH and add a new agent.
Name the new agent with the DDH's serial number.
Use the agent code from the website to finish the installation omn the DDH.
Confirm that the connection works.

## Updating the new DDH

Since this is cloned disk, it can contain slightly outdated DDH application or settings.

Click the terminal icon on the desktop. Now type:

```console
ddu
```

Choose the option ``DDH update``. This will update the DDH application and API.

If there is one, also choosen ``MAT update``. This will update the MAT library.

Once it is done, choose the option ``DDH provision``. This will update the DDH configuration settings. (JOAQUIM TODO)

## Choosing the power shield option for the DDH

Paste the commands below in the command line. 

When asked, ``enable`` the first option (RTC) and ``skip`` the remaining 3 (CAN, RS485, MAX-M8Q GNSS).

```console
cd /home/pi/li/ddt;
./dt_install_power.sh force
```

## Customize the DDH

The firmware on the cell shield cannot be automated since the boards come from the provider with unknown version.

Please check the document README.md, section ``Cell shield firmware update`` for this.

The repository ``ddt_quectel`` is already present in folder ``/home/pi/li/ddt_quectel`` of your DDH.


## Adding the DDH to the Dashboard

Add DDH to the VPN (Joaquim TODO).

Press the "add new DDH" on the Dashboard main page.

