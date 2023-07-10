# Base Linux | raspberryOS

Instructions to install a base Linux system on a Raspberry Pi that will host a DDH instance later.



## Introduction

Download base image ```2022-09-22-raspios-bullseye-armhf.img``` from the following link.

[raspios 2022](https://drive.google.com/file/d/1ydjJiUCTUBVqvDyzErxvnI1JxK9sD-x8/view?usp=sharing)

Download image flasher utility ```Raspberry PI imager``` and run it.

[raspberry imager](https://www.raspberrypi.com/software/)

On RPI imager, select ```Operating system``` to the base image file just downloaded.

On RPI imager, select ```Choose storage``` to your target storage, either SD or SSD disk.

On RPI imager, select ```Settings```, that is, the small wheel on the bottom rightmost part.

- Set "user" as pi and password as "li_ddh_82!!". No quotes.
- Set your "wi-fi information" so when your Pi first boots ever, it will join your wi-fi automatically.
- Set "locale" and "keyboard" settings.

Press ```Write```. The process can take around 10 minutes for a 32 GB storage device.

When done, remove the disk / card. You can do several ones in a row by just keep pressing ```Write```.

Connect your newly flashed device to your DDH box and boot it. After a few reboots, you will end up in the desktop.


