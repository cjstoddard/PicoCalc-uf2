I have been asked to do a step by step guide to writing the Ubuntu image to the SD card. This proceedure is really more complicated than it needs to be, but here it is. First, I use Debian Linux 13, this works on Debian 12 as well. It should work on any recent version of Ubuntu as well.

First things first, lets install the needed software.

> sudo apt install adb 7zip wget

Next download the image, this takes a few minutes, so be patient.

> git clone https://github.com/markbirss/ubuntu-24.04.2-picocalc.git
>
> cd ubuntu-24.04.2-picocalc
>
> rm -fr .git/
>
> cd image
>
> 7z x image.7z.001
>
> cd '[18Jun2025]'

Download the upgrade tool.

> wget https://files.luckfox.com/wiki/Core3566/upgrade_tool_v2.17.zip
>
> unzip -j upgrade_tool_v2.17.zip upgrade_tool_v2.17_for_linux/upgrade_tool
>
> chmod +x upgrade_tool

Insert your SD card in the Lyra, then hold down the BOOT button on the Lyra and plug it in. Give it a moment and then test to make sure the Lyra is being seen by the tool.

> ./upgrade_tool LD 

You should get output something like this.

> DevNo=1	Vid=0x2207,Pid=0x350f,LocationID=132	Mode=Loader	SerialNo=

Next we need to erase the flash. This step generates some weird messages, but seems to work regardless.

> sudo ./upgrade_tool EF MiniLoaderAll.bin

Next we need to change the active storage device to the SD card.

> sudo ./upgrade_tool SSD

Choose 2, I know it says EMMC, it is wrong, it is the SD Card. Now we can write Ubuntu image to the SD card.

> sudo ./upgrade_tool uf update.img 

Once it is finished, it should reboot. If your Lyra is installed in your PicoCalc, you should see the boot process start. If you did this before installing the Lyra, give it a couple of minutes to finish the boot process, then use adb to make sure everything worked.

> adb shell

If all went well you should see the Lyra shell prompt.