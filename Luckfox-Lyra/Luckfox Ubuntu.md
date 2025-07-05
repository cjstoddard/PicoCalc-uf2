# Luckfox Ubuntu

Since I got my second PicoCalc, I have been using a Lucjfox Lyra in it. Originally I used the Hisptoot image. This image is a serious pain in the butt to get working the way I wanted it to work. It lacks just about everything I needed to have a usable hand terminal. Most software needed to be compiled from source and the image had a very lackluster set of tools to do that forcing me to use a couple of work a arounds. On top of that, I had to jailbreak it out of a command-launcher and that just anooyed me. A couple of weeks ago a new image was realsed by Markbliss, which solved all the issues I had with the first image. If you are going to use a Luckfox Lyra in a PicoCalc, the Ubuntu image is the way to go.

You can get the image for Ubuntu Image for a Luckfox Lyra, installed in a Pico Calc, here;

https://github.com/markbirss/ubuntu-24.04.2-picocalc

Username: lyra Password: luckfox

Unfortunately, this image does not come with much in the way of wifi drivers, the board does not even have wireless to begin with. This is a very solvable problem. These two items will allow you to provide both wireless and bluetooth to the device. This fits nicely inside the case and does not require and soldering.

[MX1.25 4Pin to USB Cable](https://www.amazon.com/dp/B0DRD5792W?ref=ppx_yo2ov_dt_b_fed_asin_title)

[TP-Link Nano](https://www.amazon.com/dp/B0BJ7XJ27X?ref=ppx_yo2ov_dt_b_fed_asin_title&th=1)

Once you have installed the cable and wifi dongle, you will need to compile and install the driver. In the lyra user folder, there is a wireless folder which contains what you need. First you will need to get the kernel headers and some sym links into the right place, is done by the following;

> cd /usr/src/linux-6.1.99
>
> sudo make menuconfig

Then follow the menu into Device Drivers > Network device support > Wireless LAN, and enabled Realtek devices, I also set “Realtek 8187 and 8187B support” and “Realtek rtlwifi family of devices” to build as modules, then saved the config and exited. After that I ran;

> sudo make -j3 modules_prepare; sudo make -j3 modules; sudo make -j3 modules_install; sudo depmod -a

Once that is done, you can then go build the wireless drivers that are actually needed.

> cd /home/lyra/wireless/rtw88
>
> sudo make -j3 install
>
> sudo make install_fw
>
> sudo mkdir -p /lib/firmware/rtw88
>
> sudo  cp /lib/other/firmware/rtw88/* /lib/firmware/rtw88/
>
> sudo reboot

Once you have rebooted, run nmtui to connect to your wireless network.

The next thing I would do is get rid of that Luckfox logo the vomits all over the screen when you log in.

> sudo nano /etc/update-motd.d/00-header

If you are not sure what to delete, just delete everything in the file, then save and exit.

The next step is to create a new user for yourself. This will add a user and put the user in the sudo group.

> sudo adduser username
>
> sudo usermod -a -G sudo username

Once this is done, log out and log back into your new user account.

The next thing to do is test everything by updating the system software.

> sudo apt update
>
> sudo apt upgrade -y
>
> sudo apt autoremove -y
>
> sudo apt clean

You can now delete the lyra user account, this frees up some drive space for you.

> sudo userdel -r lyra

I personally did not need the meshtastic or the speedstest software, if you do not need it either, you can remove it;

> sudo apt remove meshtasticd speedtest-cli
>
> sudo rm /etc/apt/sources.list.d/mesh*
>
> sudo rm /etc/apt/sources.list.d/ook*

After that it is just a matter of installing the software you need, adjust to taste.

> sudo apt install links cmus tty-clock calcurse emacs-nox sc tpp wordgrinder alpine -y

The last thing I did was change the console font to make things easier to read.

> sudo apt install console-setup
>
> sudo dpkg-reconfigure console-setup

- Choose "UTF-8" and press enter.
- Choose "Guess optimal character set" and press enter.
- press enter after reading the dialog.
- Unless you have a specific preferance on the list, choose "Let system choose suitable font" and press enter.
- Again, unless you have a specific preferance, choose "6x12 (framebuffer only)" and press enter.

Give it a minute finish and when it drops to the command prompt, it should be much easier to read.