# $${\color{blue}DDHv5 \space Prepare \space Read-Only \space Disk}$$

In this procedure, we will use a golden board as a base to create a DDH disk that we will further personalize and **lock as read-only**.

🦊 Use ``FoxClone`` to **mirror** a golden board to a new card or disk. Beware you might need to retry.

⚡️ **Boot** this new card or disk in your target DDH. 

🛜 Write down its **wi-fi IP address**, p.e. 192.168.0.x.

🌐 The origin golden board's disk might come from a golden board with a **wrong DWS** and/or **timezone**. Let's **re-install** it. 

```sh
ssh pi@192.168.0.x "sudo /home/pi/Downloads/dwagent.sh uninstall"
ssh pi@192.168.0.x "sudo /home/pi/Downloads/dwagent.sh install"
ssh pi@192.168.0.x "sudo dpkg-reconfigure tzdata"
```

🌐 Ask **$${\color{red}Joaquim}$$** to install **VPN**.

🔒 Prepare to set the **drive as read-only** by creating file `/etc/overlayroot.local.conf` with the following content:

```sh
ssh pi@192.168.0.x "echo 'overlayroot=tmpfs:recurse=0' | sudo tee /etc/overlayroot.local.conf"
```

⚡️ **Reboot to apply the overlay** with:

```sh
ssh pi@192.168.0.x "sudo reboot"
```

🔒 This cloned drive **root partition is $${\color{red}READ-ONLY \space NOW}$$**. 

Edit `/etc/fstab` to make the **/boot partition read-only**.

```sh
sudo overlayroot-chroot
joe /etc/fstab
```

🔒 **Change** the following (add ro) in `/etc/fstab`.

```
PARTUUID=<WHATEVER_UUID>-01		/boot/firmware				vfat    defaults,ro		0       2
```

⚡️ **Reboot to apply the /boot read-only** with:

```sh
ssh pi@192.168.0.x "sudo reboot"
```

🔒 This cloned drive **boot partition is $${\color{red}READ-ONLY \space NOW}$$**.

📞 Check if you need to **update the cell shield's firmware** by:

```sh
ssh pi@192.168.0.192 "echo -ne 'AT+CVERSION\r' > /dev/ttyUSB2 && cat -v /dev/ttyUSB2"
```

Anything different than **2022** needs update. Refer to `ddt_quectel` repository.

**Edit** file `/li/ddh/settings/config.toml`. Once properly filled, the DDH GUI will start automatically.

Run tool `ddc` to make sure all DDH configuration is OK.

🌐 Add this DDH to the **dashboard**.



### $${\color{blue}Overlay \space Debug \space Commands}$$

If needed, you can $${\color{red}UNLOCK}$$ the respective `boot` and `root` partitions with:

```sh
sudo mount -o remount,rw /boot/firmware
sudo overlayroot-chroot
```

We can also **disable the overlay(( by setting ``overlayroot=disabled`` in ``/boot/firmware/cmdline.txt``

You can check if overlay is enabled by finding the `overlay` word in the output of:

```sh
df -h
```
