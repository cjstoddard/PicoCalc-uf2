# Programs known to successfully compile

This is a list of programs I have successfully built and run on my PicoCalc with the Luckfox Lyra board modification, running hiptoot's Lyra Linux build. There are three ways to accomplish this; natively on the PicoCalc, using hiptoot's [buildroot](https://github.com/cjstoddard/PicoCalc-uf2/blob/main/Luckfox-Lyra/Lyra%20Cross%20Compiler.md) environment and using a [Raspberry Pi Zero](https://github.com/cjstoddard/PicoCalc-uf2/blob/main/Luckfox-Lyra/Compiling-Programs.md). Some programs will compile on all three, however compiling programs natively or on the Pi Zero can be slow (and I do mean slow), so even if it will compile in those envrionments, large programs should use the buildroot if possible.

====================

cfiles (text mode file manager)

Compiles on the PicoCalc natively.

> git clone https://github.com/mananapr/cfiles.git
>
> cd cfiles
>
> gcc cf.c -lncurses -o cf
>
> sudo cp cf /usr/local/bin
>
> sudo chown root:root /usr/local/bin/cf

Note: Do not use the Makefile, it will try to use the ncursesw library and fail to build.

====================

Joe (Emacs like text editor)

Compiles on the Raspberry Pi Zero or in the buildroot.

==Building on a Pi Zero==

> wget https://sourceforge.net/projects/joe-editor/files/JOE%20sources/joe-4.6/joe-4.6.tar.gz
>
> tar -xvzf  joe-4.6.tar.gz
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

==Alternately using buildroot==

> wget https://sourceforge.net/projects/joe-editor/files/JOE%20sources/joe-4.6/joe-4.6.tar.gz
>
> tar -xvzf joe-4.6.tar.gz
>
> cd joe-4.6
>
> ./autojoe
>
> ./configure --prefix=/usr/local --host=arm-buildroot-linux-gnueabihf
>
> make

Once this is done, copy the joe-4.6 folder to your SDcard, then put it in your PicoCalc, boot it up, then navigate to the folder and run "sudo make install", and all should work.

====================

MMBasic for Linux (Basic interpreter)

Compiles on the Raspberry Pi Zero.

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

Note: This takes a while to build, be patient.

====================

nethack (Old school dungeon crawl classic)

Compiles on the Raspberry Pi Zero.

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

Copy the entire NetHack-3.6.7 directory to the PicoCalc, then log into the PicoCalc, cd into the NetHack-3.6.7 directory, and type the following commands;

> make install
>
> echo '#!/bin/bash' > nh.sh
>
> echo '~/nh/install/games/nethack' >> nh.sh
>
> sudo cp nh.sh /usr/local/bin
>
> sudo chmod +x /usr/local/bin/nh.sh
>
> sudo chown root:root /usr/local/bin/nh.sh

Type nh.sh to play the game.

====================

Picoarch (Frontend for game emulators)

Compiles in the buildroot.

https://github.com/gurubook/picoarch

Note: His buildroot configuration is more or less the same as mine, he just chose a different top level directory name.

====================

PicoCalc Lyra Ebook Reader

Compiles on the PicoCalc natively.

https://github.com/cjstoddard/PCL-Ebook-Reader

====================


