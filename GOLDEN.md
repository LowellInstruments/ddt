# $${\color{blue}DDHv5 \space Golden \space Board}$$

A golden board is $${\color{red}NOT}$$ meant to run but be used as source to clone othere DDH drives.

## Use your laptop

Download the latest RaspberryOS Bookworm [2025 image](https://downloads.raspberrypi.com/raspios_oldstable_arm64/images/raspios_oldstable_arm64-2025-11-24/2025-11-24-raspios-bookworm-arm64.img.xz).

Connect a **blank** microSD card or SSD disk via USB.

Run `RPI imager`. **Enable SSH public key access**.

Set the **wi-fi credentials** so on first boot we join the wi-fi network automatically. 

Set **locale** and **keyboard** settings.

Choose to `Apply` all these settings.




## Use target DDH

⚡️ **Boot the freshly flashed microSD card** or disk into the target DDH. 

📁 This first boot automatically **expands the filesystem**. 

Wait full boot, shutdown DDH and **remove disk**.




## Use another DDH already running

**Connect the microSD card** or SSD disk to a DDH already running. The running OS will detect it as a second disk.

🇵 Install and run the tool called `gparted`. Choose probably `/dev/sdb`. **Shrink big root partition** and **create new EXT4 one at end of disk** (10 GB).

**Remove** your microSD card or disk.




## Again, use target DDH

⚡️ Insert microSD card and **boot**.

After booting, you might need to press the icon to **Activate Wi-fi**. 

🛜 Write down the **IP address** assigned to this DDH so you can **ssh** to it.

Ensure **SSH is enabled** by typing:

```sh
sudo systemctl start ssh && sudo systemctl enable ssh
```

To start with a fresh package base in this OS, you might need:

```sh
sudo rm -rf /var/lib/apt/lists/*                        && \
sudo apt update                                         && \
sudo apt-get -y install overlayroot joe gparted
```

🇵 **Add the following at the end of file** `/etc/fstab`:

```sh
PARTUUID=<_____copythis_from_above_lines_______>-03  /li ext4 defaults noatime,sync,nofail   0 0
/li     /home/pi/li     none bind
```
👆 **Ensure** you did not forget the last line starting with `/li` and its **newline**. It's essential.

🌐 **Install nomachine**.

```sh
cd /home/pi/Downloads                                                                    && \
wget https://web9001.nomachine.com/download/9.3/Raspberry/nomachine_9.3.7_1_arm64.deb    && \
sudo dpkg -i nomachine_9.3.7_1_arm64.deb
```

Also switch on **Bluetooth icon** in the panel.

#⃣️ If **On-Screen Keyboard** is in the way, **disable it** in `Menu > Preferences > Control Centre > Display`.

⚡️ Reboot RPi.

**Install DDTv5 required Linux libraries on RW partition /li** with:

```sh
ls /li                                                                      && \
sudo chown -R pi:pi /li                                                     && \
cd /li                                                                      && \
git clone https://github.com/lowellinstruments/ddt.git --depth 1 -b ddt5    && \
cd /li/ddt                                                                  && \
./dt_install_step_1_linux.sh                                                && \
echo -e "\n\neverything went smooth for install_step_1_linux\n\n"
```

**Install DDTv5 required DDH and API on RW partition /li** with:

```sh
cd /li/ddt                                                                  && \
./dt_install_step_2_ddh.sh                                                  && \
./dt_install_step_3_api.sh                                                  && \
echo -e "\n\neverything went smooth for install_step_2_and_3\n\n"
```

**Install GOR virtual environment** for alarm script, type:

```sh
python3 -m venv /home/pi/venv_gor                                 && \
source /home/pi/venv_gor/bin/activate                             && \
/home/pi/venv_gor/bin/pip3 install boto3 pyserial                 && \
deactivate                                                        && \
cp /li/ddt/_dt_files/main_mnt.cpython-311.pyc /home/pi            && \
cp /li/ddt/_dt_files/run_mnt.sh /home/pi                          && \
echo -e "\n\neverything went smooth for install_gor\n\n"
```

**Download DWS** but not install it yet.

```sh
    wget https://www.dwservice.net/download/dwagent.sh -O /home/pi/Downloads/dwagent.sh && \
    chmod +x /home/pi/Downloads/dwagent.sh
```

**Download newest cell firmware** but not install it yet.

```sh
    cd /home/pi/Downloads && \
    git clone https://github.com/lowellinstruments/ddt_quectel.git --depth 1
```



⌛ **Edit file** `/etc/crontab` and **uncomment entries** for ▶️ `redis` ▶️ `DDH` ▶️ `gor/run_mnt.sh`.

🌐 Set **timezone** with:

```sh
sudo dpkg-reconfigure tzdata
```

🪟 For DWS (installed later) to not complain, you might need to run `raspi-config` and choose **X11 instead of Wayland** inside ``Advanced Options``.

⚡️ **Reboot for the X11 change to make effect**. Let it full boot. 

🗑️ Connect via Nomachine or presentially and **remove Bluetooth, software updater and ejecter upper panel icons** by right-clicking on them.

**Disable screensaver** by `Click menu / Preferences / Screen Saver`. Next to `mode`, you can disable it. Use a mouse if the drop-down does not open properly.

**Disable screen blanking** by `Click menu / Preferences / Raspberry Configuration / Display`.

**Right-click desktop and hide /li volume** icon.

If needed, **change wallpaper** to the one in ``/home/pi/li/ddt/_dt_files/wp_ddh.jpg``.

🖼️ Change the **splash screen** by:

```sh
    sudo cp /home/pi/li/ddt/_dt_files/splash.png /usr/share/plymouth/themes/pix/splash.png     && \
    sudo plymouth-set-default-theme -R pix                                                     && \
    echo -e "\n\neverything went smooth changing wallpaper\n\n"
```

⚡️ **Shutdown**. Keep this golden board safe.
