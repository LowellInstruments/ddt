# $${\color{blue}DDHv5 \space Prepare \space Read-Only \space Disk}$$

This procedure uses a golden board as a **source** to create a cloned DDH disk that we will personalize and **lock as read-only**.

🦊 Use ``FoxClone`` to **mirror** the source golden board to a new card or disk. Beware you might need to retry.

⚡️ **Boot** the newly created card / disk on your target DDH. 

🛜 Write down its **wi-fi IP address**, p.e. 192.168.0.x. and SSH to it.

⬛ $${\color{blue}Step \space 1:}$$ make sure **screen blanking is disabled in raspi-config**, `Display Options / Screen Blanking`.

```sh
sudo raspi-config
```

🌐 $${\color{blue}Step \space 2:}$$ the golden board's disk might have a **wrong DWS** and/or **timezone**. 

```sh
sudo dpkg-reconfigure tzdata
sudo /home/pi/Downloads/dwagent.sh uninstall
```

🌐 Now **install DWS**.

```sh
sudo /home/pi/Downloads/dwagent.sh install
```

🌐 $${\color{blue}Step \space 3:}$$ ask **$${\color{red}Joaquim}$$** to install **VPN**.

🔒 $${\color{blue}Step \space 4:}$$ set **root partition as read-only** with:

```sh
echo 'overlayroot=tmpfs:recurse=0' | sudo tee /etc/overlayroot.local.conf
```

⚡️ **Reboot to apply the overlay** with:

```sh
sudo reboot
```

This DDH's **root partition (1 / 2)** is **$${\color{red}READ-ONLY \space NOW}$$**. 

🔒 $${\color{blue}Step \space 5:}$$ Edit `/etc/fstab` to make the **/boot partition read-only**.

```sh
sudo overlayroot-chroot
joe /etc/fstab
```

**Change** the following (add ro) in `/etc/fstab`.

```
PARTUUID=<WHATEVER_UUID>-01		/boot/firmware				vfat    defaults,ro		0       2
```

⚡️ **Reboot to apply the /boot read-only** with:

```sh
sudo reboot
```

🔒 This cloned drive's **boot partition (2 / 2)** is **$${\color{red}READ-ONLY \space NOW}$$**.

📞 🔒 $${\color{blue}Step \space 6:}$$ Check if you need to **update the cell shield's firmware** by:

```sh
echo -ne 'AT+CVERSION\r' > /dev/ttyUSB2 && cat -v /dev/ttyUSB2
```

Anything different than **2022** needs update. Refer to `ddt_quectel` repository.

**Edit** file `/li/ddh/settings/config.toml`. Once properly filled, the DDH GUI will start automatically.

Run tool `ddc` to make sure all DDH configuration is OK.

🌐 🔒 $${\color{blue}Step \space 7:}$$ Add this DDH to the **dashboard**.



### $${\color{blue}Overlay \space Debug \space Commands}$$

If needed, you can $${\color{red}UNLOCK}$$ the respective `boot` and `root` partitions with:

```sh
sudo mount -o remount,rw /boot/firmware
sudo overlayroot-chroot
```

We can also **disable the overlay** by setting ``overlayroot=disabled`` in ``/boot/firmware/cmdline.txt``.

You can check if overlay is enabled by finding the `overlay` word in the output of:

```sh
df -h
```
