# Programs known to successfully compile

This is a list of programs I have successfully built and run on my PicoCalc with the Luckfox Lyra board modification, running hiptoot's Lyra Linux build. There are three ways to accomplish this; natively on the PicoCalc, using hiptoot's [buildroot](https://github.com/cjstoddard/PicoCalc-uf2/blob/main/Luckfox-Lyra/Lyra%20Cross%20Compiler.md) environment and using a [Raspberry Pi Zero](https://github.com/cjstoddard/PicoCalc-uf2/blob/main/Luckfox-Lyra/Compiling-Programs.md). Some programs will compile on all three, however compiling programs natively or on the Pi Zero can be slow (and I do mean slow), so even if it will compile in those envrionments, large programs should use the buildroot if possible.

If you wish to contribute to this list, open an issue, provide me with the name of the program, what environment you used to compile it and step by step instructions for building and installing it. If your have a github or other site that walks though the process, you can just provide the link, and I will add it to the list as quick as I can.

====================

cfiles (Text mode file manager)

Compiles on the PicoCalc natively. Builds in just a few seconds.

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

Once this is done, copy the joe-4.6 folder to your SDcard, or transfer it over using scp, then navigate to the folder and run "sudo make install", and all should work.

====================

LinksWWWbrowser (Text mode web browser)

This compiles locally, on the Pi Zero and in the buildroot.

> git clone https://github.com/nmbazima/LinksWWWbrowser.git
>
> cd LinksWWWbrowser
>
> chmod +x configure
>
> chmod +x missing
>
> mkdir build && cd build
>
> ../configure --disable-utf8 --without-gpm --without-zlib --without-x --without-libjpeg --without-libtiff --without-librsvg --prefix=/usr/local
>
> make

If you are compiling this on the PicoCalc, you just need to type "make install". If you are using the Pi Zero or the buildroot, you will need to copy the entire LinksWWWbrowser directory over to the PicoCalc and then run "make install" on the PicoCalc.

Note: If you are using the buildroot cross compiler, add --host=arm-buildroot-linux-gnueabihf to the end of the ./configure command.

====================

MMBasic for Linux (Basic interpreter)

Compiles on the Raspberry Pi Zero. This takes a while to build, go have lunch or watch a movie while this builds.

> git clone --recursive https://github.com/thwill1000/mmb4l.git
>
> cd mmb4l
>
> sudo apt install libsdl2-dev
>
> ./build.sh
>
> cp build/build-release-armv6l-raspbian-11-gcc-20210110/mmbasic ~/
>
> cd

Now copy the mmbasic program over to your PicoCalc, either with the SDcard or with scp and copy it to /usr/bin or /usr/local/bin.

====================

nethack (Old school dungeon crawl classic)

Compiles on the Raspberry Pi Zero. This takes some time to build, but its not too bad.

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

Compiles on the PicoCalc natively. Builds in just a few seconds.

https://github.com/cjstoddard/PCL-Ebook-Reader

====================

simh (Historic simulator of classic computers)

This builds locally on the PicoCalc Lyra. Individually each one takes several minutes to compile. If you try to make them all, it will probably take several hours. I recommend just building the ones you are actually interested in. For more information and additional software kits, please vist the [Computer Simulation and History](https://simh.trailing-edge.com/) site.

> git clone https://github.com/simh/simh.git
>
> cd simh
>
> make pdp10
>
> sudo cp BIN/pdp10 /usr/local/bin
>
> cd

Substitute pdp10 with whatever simulator you want to build. I am not 100% sure all of them will build, but the few I built did work, so YMMV. The next steps are for downloading a quick and easy preconfigured pdp10 setup called [TOPS-in-a-Box](https://www.filfre.net/2011/05/tops-10-in-a-box/). It is a fairly complete TOPS PDP10 setup, please, please read the README.txt file before running it, so you know what to do.

> wget https://www.filfre.net/misc/TOPS-10.zip
>
> unzip TOPS-10.zip
>
> mkdir tops
>
> mv TOPS-10.zip tops/
>
> cd tops
>
> unzip TOPS-10.zip
>
> pdp10 tops10.cfg



====================

tty-clock (ncurses clock)

Compiles on the Pi Zero.

> git clone https://github.com/xorg62/tty-clock.git
>
> cd tty-clock
>
> make

Copy the entire tty-clock directory to the PicoCalc and run "make install"

====================


