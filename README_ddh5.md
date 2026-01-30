## $${\color{blue}Creating \space read-only \space GOLDEN \space board}$$

This procedure involves several architectures so we will have to switch the disk a couple times. Luckily, creating the golden board only happens once.

### On your laptop

Connect a **blank** microSD card or SSD disk via USB.

Run `RPI imager`. **Enable SSH public key access**.

Proceed to download the latest Bookworm [2025 image](https://downloads.raspberrypi.com/raspios_oldstable_arm64/images/raspios_oldstable_arm64-2025-11-24/2025-11-24-raspios-bookworm-arm64.img.xz).

For old DDH versions, [2023 image](https://downloads.raspberrypi.com/raspios_oldstable_arm64/images/raspios_oldstable_arm64-2023-12-06/2023-12-05-raspios-bullseye-arm64.img.xz).

### Target DDH

Boot the freshly flashed microSD card into the **target DDH** so it **expands the filesystem**.

Wait for a full boot, shutdown this DDH and remove disk.

### On another different DDH, already running

**Connect the microSD card** or SSD disk. It will probably appear as `/dev/sdb`.

Install and run `gparted`. **Shrink tmain partition** and **create new EXT4 one at end of disk** (10 GB).

Disconnect microSD card from this DDH already running.

### Target DDH

Insert microSD card and **boot it**.

After booting, you might need to press the network icon to **Activate Wi-fi**. Also the **Bluetooth icon** in the panel. Write down the **IP address** assigned to this DDH.

If **On-Screen Keyboard** is in the way, **disable it** in `Menu > Preferences > Control Centre > Display`.

To start, you might need:

```console
    sudo rm -rf /var/lib/apt/lists/*
    sudo apt update
```

Ensure **SSH is enabled** by typing:

```console
    sudo systemctl start ssh && sudo systemctl enable ssh
```

**Edit file** `/etc/fstab` like this:

    PARTUUID=<_____copythis_from_above_lines_______>-03  /li ext4 defaults,noatime,sync 0 0
    /li     /home/pi/li     none bind

**Reboot RPi**.

Wait for full boot. Test partition /li is present:

```sh
    ls /li
```

**For new DDH5 version, install DDT on RW partition /li** with:

```console
    sudo chown -R pi:pi /li                                                     && \
    cd /li                                                                      && \
    git clone https://github.com/lowellinstruments/ddt5.git --depth 1           && \
    mv ddt5 ddt                                                                 && \
    cd /li/ddt                                                                  
```

**For new DDH5 version, run** the first scripts of the installer.

```console
    dt_install_step_1_linux.sh
    dt_install_step_2_ddh.sh
    dt_install_step_3_api.sh
```

**For legacy DDHv4 version** do instead:

```console
    sudo chown -R pi:pi /li                                                     && \
    cd /li                                                                      && \
    git clone https://github.com/lowellinstruments/ddt.git --depth 1 -b toml    && \
    cd /li/ddt                                                                  && \
    dt_install_all.sh force                                                                  
```

**Install GOR virtual environment** for alarm script, type:

```console
    python3 -m venv /home/pi/venv_gor                    && \
    source /home/pi/venv_gor/bin/activate                && \
    /home/pi/venv_gor/bin/pip3 install boto3 pyserial    && \
    deactivate  
```

__Edit file__ `/etc/crontab` and uncomment entries for DDH and `gor/run_mnt.sh`.

Copy `gor` files via **SCP**, type:

```console
    scp main_mnt.py run_mnt.sh pi@<_______yourDDHIpAddress_________>:/home/pi
```

Remove Bluetooth and software updater **upper panel icons** by right-clicking on them.

**Disable screensaver** by `Click menu / Preferences / Screen Saver`. Next to "mode", you can disable it. Use a mouse in case the drop-down does not open properly.

**Disable screen blanking** by `Click menu / Preferences / Raspberry Configuration / Display`.

You can now use this Golden Board to clone more DDH disks using programs like `FoxClone`. **It is $${\color{red}NOT \space READ-ONLY \space protected \space yet}$$**.

## $${\color{blue}DDH5 \space - \space Boot \space and \space lock \space the \space cloned \space DDH}$$

Set the **cloned drive as read-only** by installing the following:

```console
    sudo apt install overlayroot
```

And by creating file `/etc/overlayroot.local.conf` with the following content:

```console
    overlayroot=tmpfs:recurse=0
```

Edit `/etc/fstab` to make **boot partition read-only**.

```console
    PARTUUID=<WHATEVER_UUID>		/boot				vfat    defaults,ro,flush		0       2
```

**For DDH5**, if something goes $${\color{red}WRONG}$$, you can unlock the respective `boot` and `root` partitions with:

```console
    sudo mount -o remount,rw /boot/firmware
    sudo overlayroot-chroot
```

## $${\color{blue}DDH4 \space - \space Boot \space and \space lock \space the \space cloned \space DDH}$$

Run:

```sh
    raspi-config
```

Go to `Performance options`, set the **overlay and read-only boot partition**.

**Reboot**.

**For DDH4**, if something goes $${\color{red}WRONG}$$, run `raspi-config` again.

## $${\color{blue}Customize \space cloned \space DDH}$$

This cloned drive **is $${\color{red}READ-ONLY \space NOW}$$**. You can check by finding the `overlay` word in the output of:

```console
    df -h
```

Install **DWService** and set the **timezone** with:

```console
    sudo dpkg-reconfigure tzdata
    /home/pi/li/ddt/dt_install_step_4_dws.sh     && \
    sudo /home/pi/Downloads/dwagent.sh
```

You might need to run `raspi-config` and choose **X11 instead of Wayland**.

Ask **$${\color{red}Joaquim}$$** to install **VPN** with:

```console
    /home/pi/li/ddt/dt_install_step_5_vpn.sh <____yourassignedVPN_IP_____>
```

Check if you need to **update the cell firmware** by sending AT+CVERSION to `/dev/usb2`. Anything different than 2022 needs update.

If needed, please see `ddt_quectel` repository.

**Edit** file `/li/ddh/settings/config.toml`.

Run tool `ddc` to make sure DDH is OK.

## $${\color{blue}Dashboard}$$

Add this DDH to it.
