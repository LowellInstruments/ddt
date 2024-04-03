## Different Raspberry Hardware versions

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
