# Compiling programs

The PicoCalc Lyra Linux build lacks the development tools and libraries needed to build many programs. The buildroot sdk does not make it easy to add these things. Plus it is counter productive to rebuild a whole new image to add a single program. The goal here is to make a development environment anyone can duplicate and build the programs they want to use, then copy the program to an SD card or use scp to transfer the program to the PicoCalc.

I am a Linux user and have been since the 1990's, setting up a build environmet to cross compile programs is not really a problem for me. However, I understand that most people are neither Linux user nor developers, so setting something like that up can be a serious challenege. If you want to do this, there are plenty of good guides out there on the internet, or you can go ask ChatGPT.

The maintaner of the PicoMite Basic image for the PicoCalc, adcockm pointed out that the Raspberry Pi 1 and by extension, the Raspberry Pi Zero use CPU's compatible with the Lyra. He tested the hypothisis by building MMBasic on one and seeing if the binary would run on the Lyra and it worked, so I set out to write this guide. Raspberry Pi Zero's are still in production and still reasonably cheap. If all you are going to do with it is build a few programs, get a Zero W, so you don't need a keyboard and monitor, you can just ssh into the device and do what you need to do. Once you are done, you can repurpose the Zero for another project.

Keep in mind, the Pi Zero is not a fast device and the build process for these programs can take a very long time. MMBasic took a couple of hours and Wordgrinder ran overnight. So each time you start compiling a program, plan on going and doing something else for a while. 

Start with a Raspberry Pi Zero, preferably a Zero W. These have a compatible CPU. Go here;

https://www.raspberrypi.com/software/operating-systems/

Download the Raspberry Pi OS (Legacy) Lite image and burn it to your SD card. Put the SD card in the Pi Zero and boot it up and let it do its thing.

Now run the always necessary updates;

> sudo apt update && sudo apt upgrade
>
> sudo reboot

Next install the needed tool chain for the various programs to be built. These are the ones I ended up needing, there may be others depending on what you are compiling, but the build process will tell you what you need.

> sudo apt install bc bison build-essential curl flex git mc wget cmake autoconf autopoint -y

Next, I want to make a place where we can place our newly compiled programs, so we don't have to go hunting for them. We also want to keep are source code in one place as well.

> mkdir bin
>
> mkdir src
>
> cd src

Before we start compiling programs, it is improtant to note that you need to read the install documents that are usually included with the source code. The build process varies wildly between projects, so before you do anything else, read the instructions and adapt them to what needs to be done here. You will want to pay special attention to things like "./configure --prefix=" options, because you do not want to install the programs on the Pi, you want to contain the install, so it can be easily transfered to the PicoCalc.

Now we start building programs.

----------
MMBasic for Linux (Basic interpreter)
> git clone --recursive https://github.com/thwill1000/mmb4l.git
>
> cd mmb4l
>
> sudo apt install libsdl2-dev
>
> ./build.sh
>
> cp build/build-release-armv6l-raspbian-11-gcc-20210110/mmbasic ~/bin/
>
> cd ..

----------
Joe (Emacs like text editor)
> wget https://sourceforge.net/projects/joe-editor/files/JOE%20sources/joe-4.6/joe-4.6.tar.gz
>
> tar -xvzkf joe-4.6.tar.gz
>
> cd joe-4.6
>
> ./autojoe
>
> ./configure --prefix=$HOME/bin/joe
>
> make
>
> make install
>
> cp /lib/arm-linux-gnueabihf/libtinfo.so.6 ~/bin/joe/bin/libtinfo.so.6
>
> echo "#!/bin/sh" > ~/bin/joe.sh
>
> echo "~/bin/joe/bin/joe" >> ~/bin/joe.sh
>
> chmod +x ~/bin/joe.sh
>
> cd ..

Note: When you copy it over to the PicoCalc, you will need to run these commands;
> sudo cp ~/bin/joe/bin/libtinfo.so.6 /lib
>
> sudo chown root:root /lib/libtinfo.so.6

----------
Once you are done building the programs you want to build, just copy the bin folder to your SDcard, place it in your PicoCalc and copy it to your home diriectory. Personally, I just left it there and added "~/bin" to my PATH in /etc/profile.

When I first compiled MMBasic, the build failed because I was missing a needed development library and I had to install libsdl2-dev. This happens occassionally. Usually Google will be happy to tell you what needs to be installed if you have trouble figuring it out from the error message.

You will notice there is an extra couple of steps in the Joe build. This is because Joe needed libtinfo.so.6, but it was not on the PicoCalc and when I originally tried it, I got a library missing error. If this happens to you, use this command to find the library you are missing.

> ldd programname

Example;

> ldd ~/bin/joe/bin/joe

This will tell you what is missing. Now go back to the Pi Zero and do the same thing, it will tell you where the library is at, just copy that file to your SD card, take it back to your PicoCalc and copy it to the location where it was on the Pi Zero, if in doubt, just put it in /lib.

Honestly, this is probably not the best way to do this. This is not a perfect solution and some programs are just not going to build. It is frustrating, I know. Setting up a desktop system or even a virtual machine to do the building is faster and give you the same results. However until the Lyra buildroot is updated to include a more complete tool chain and if all you want to do is compile a couple of programs and move on with your life, this will do just fine.

Update 5-11-2025:

Nethack does not compile on the PicoCalc Lyra or in the buildroot, but it does compile on the Raspberry Pi Zero.

nethack (Old school dungeon crawl classic)
> wget https://www.nethack.org/download/3.6.7/nethack-367-src.tgz
>
> tar -xvzf nethack-367-src.tgz
>
> cd NetHack-3.6.7/sys/unix
>
> sh setup.sh hints/linux
>
> cd ../..
> make all

Copy to PicoCalc

> make install
>
> echo '#!/bin/bash' > nh.sh
> echo '~/nh/install/games/nethack' >> nh.sh
> sudo cp nh.sh /usr/local/bin
> sudo chmod +x /usr/local/bin/nh.sh
> sudo chown root:root /usr/local/bin/nh.sh

Type nh.sh toplay the game.