## $${\color{blue}Creating \space read-only \space GOLDEN \space board}$$

This procedure involves several architectures so we will have to switch the disk a couple times. Luckily, creating the golden board only happens once.




### On your laptop

Connect a **blank** microSD card or SSD disk via USB. 

Run ``RPI imager``. **Enable SSH options**, enable **public key SSH access, no password**. Proceed to **install Linux 2025/12/04 Raspberry image 64 bits**.





### On your target DDH

Boot the microSD card so it automatically **expands the filesystem**. Wait for a full boot, shutdown this DDH and remove the disk.





### On another DDH already running

**Connect the microSD card or SSD disk via USB**. It will appear on ``/dev/sdb``. 

Install and run ``gparted``. **Shrink the main partition** and **create new EXT4 one at end of disk** (10 GB).





### Go back to your target DDH

Put the microSD card or SSD disk on the Rpi and **boot it**. 

After booting, you might need to press the network icon to **Activate Wi-fi**. Also the **Bluetooth icon** in the panel. Write down the **IP address** assigned to this DDH.

If **On-Screen Keyboard** is in the way, **disable it** in ``Menu > Preferences > Control Centre > Display``.

Ensure SSH is enabled by typing:

```console
    sudo systemctl start ssh && sudo systemctl enable ssh
```

**Edit file** ``/etc/fstab`` like this:

    PARTUUID=<_____copythisnumberfromabove_______>-03  /li             ext4    defaults,noatime  0       3

**Reboot RPi**. Wait for full boot. Test partition /li is present:

```console
    ls /li
```

**Install DDT on RW partition /li, create the softlink**, type the following:

```console
    sudo chown -R pi:pi /li                                                     &&  \
    sudo ln -s /li /home/pi/li                                                  &&  \
    cd /li                                                                      &&  \
    git clone https://github.com/lowellinstruments/ddt.git --depth 1 -b toml    &&  \
    cd /li/ddt                                                                  &&  \
    ./dt_install_all.sh 
```

For new DDHv5 versions, run script_install_step1 to 3 only.

**Install GOR virtual environment** for alarm script, type:

```console
    python3 -m venv /home/pi/venv_gor                    && \
    source /home/pi/venv_gor/bin/activate                && \
    /home/pi/venv_gor/bin/pip3 install boto3 pyserial    && \
    deactivate  
```

Copy ``gor`` files via **SCP**, type:

```console
    scp main_mnt.py run_mnt.sh pi@<_______yourDDHIpAddress_________>:/home/pi
```

On RPi:

- Remove Bluetooth and software updater **upper panel icons**. To do this, right-click on them.
- ``Click menu / Preferences / mouse and keyboard settings / 500`` to slo down the requirements to double-click.
- Edit file ``/etc/crontab`` and uncomment entries for DDH and ``gor/run_mnt.sh``.

You can now use this Golden Board to clone more DDH disks using programs like ``FoxClone``. **It is $${\color{red}NOT}$$ READ-ONLY protected yet**.




## $${\color{blue}Boot \space and \space lock \space the \space cloned \space DDH}$$

Install **DWService** and set the **timezone** with:

```console
    sudo dpkg-reconfigure tzdata
    /home/pi/li/ddt/dt_install_step_4_dws.sh     && \
    sudo /home/pi/Downloads/dwagent.sh
```

Ask **$${\color{red}Joaquim}$$** to install **VPN** (IP 76 for golden board) with:

```console
    /home/pi/li/ddt/dt_install_step_5_vpn.sh <____yourassignedVPN_IP_____>
```

Set the **cloned drive as read-only** with the following command. Use arrow and tab keys to go to ``Performance options`` set **OVERLAY FILE SYSTEM YES** and **PROTECT BOOT FROM WRITE YES** and **REBOOT**.

```console
    raspi-config
```

This cloned drive **is $${\color{red}READ-ONLY \space NOW}$$**.




## $${\color{blue}Customize \space cloned \space DDH}$$

**Update the cell firmware** if needed with:


```console
    /home/pi/li/ddt/dt_install_step_6_cell.sh
```


**Edit** file ``/li/ddh/settings/config.toml``.

Run tool ``ddc`` to make sure DDH is OK.


## $${\color{blue}Dashboard}$$

Add this DDH to it.
