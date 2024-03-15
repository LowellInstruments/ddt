# DDH Tools | ddt

Tools to install DDH. Don't manually run ```apt```. We take care of all.


## Special case of Raspberry Pi 3

Old DDH with Rpi3 might get stuck at boot on a black screen with a blinking cursor.

Pressing ```ctrl + alt + F1``` should give you time to see the remote access IP on screen.

SSH to such IP or open the disk somewhere else via USB on a computer. Edit the file ```/boot/config.txt```:

```console
dtoverlay=vc4-fkms-v3d # ensure this line says fkms, not kms, in case of error, comment it
```


## Remote access

Join your DDH to your wi-fi. Next, go to terminal and type:

```console
ifconfig -a    
```

Annotate the IP address for the wlan0 interface. 

Run any SSH client software to such IP.

Enter credentials "user" and "password" as per document BASE_LINUX.md.

---
Optional. Install DWService. Just copy-paste the following instructions.

```console
cd /home/pi/Downloads;
wget https://www.dwservice.net/download/dwagent.sh;
chmod +x /home/pi/Downloads/dwagent.sh;
sudo /home/pi/Downloads/dwagent.sh;
```
---


## Getting the installation tools

Copy-n-paste the following to get the DDH Tools ``ddt``.

```console
cd /home/pi;
mkdir li;
cd li;
git clone --branch toml https://github.com/lowellinstruments/ddt.git;
cd /home/pi/li/ddt;
```

## Turning a raspberry into a DDH

You just need to run ``./dt_install_all.sh``. 

Any further installation tweak can be done at a later time running ``ddi``.


## Cell shield firmware update

Old cell shield firmware may be from 2017 or 2019.

```console
minicom -D /dev/ttyUSB2 -b 115200
AT+CVERSION
```

For a year < 2022 in the answer, contact Lowell Instruments and we will upgrade it.


## Post configuration

Some additional useful things to do for better DDH behavior:

- Edit file ```settings/config.toml``` with project's settings and credentials.
- Go to Rpi menu, click "Preferences" and "Screen Saver". Disable it.
- Remove the Bluetooth and software updater icons from the upper panel. Right-click on them.
- Ensure ``juice4halt`` is running by checking existence of file:

``` console
ls /home/pi/li/juice4halt/bin/j4h_halt_flag
```

- Remember to edit the crontab with:

``` console
sudo nano /etc/crontab
```
  
Run the DDH software by clicking the icon on the desktop, or wait for the crontab to do it for you.
