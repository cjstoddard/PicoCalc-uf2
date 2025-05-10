# Using the Lyra Cross Compiler Environment

In my other post about using a Raspberry Pi Zero to compile programs for a PicoCalc using the Lyra mod, I mentioned setting up a desktop system or even a virtual machine to do the building is faster and give you the same results. Well, I got asked how to do that. Originally I really did not want to mess around with it, mainly because my experience with cross compiling has been a mixed bag.

However, after talking to a few people about it, they seemed to be confused about what even to do with the buildroot provided by the forum user hisptoot. Honestly, it is not that hard to do, but if you have never done it before, it can be a challenge, however hisptoot's buildroot file actually goes a long way towards making it easier to do. So here is the step by step process of getting the buildroot environment up and running, along with a small program you can build to ensure everything is working.

Before getting started, there is one caveat to using the buildroot. While it cmpiles things much quicker than either the Lyra, it has all the limitation the PicoCalc Lyra Linux has. It is missing tools like cmake and autogen, it is also missing more than a few development libraries. So some programs will just have to be built using the Pi Zero environment.

I am assuming you have some basic working knowledge of using Linux. The first thing you will need is a system running Linux. If you do not have a Linux box laying around, a virtual machine or WSL will work just fine.

Next, to compile programs for PicoCalc Lyra Linux, you will need the tools and libraries. You can get what you need here in the sdk-buildroot folder;

https://drive.google.com/drive/folders/1TBEso7NFkO7e6z8iEBywjxi4EtJHSz4F

Now open a terminal and start typing;

> mkdir lyralinux
>
> cd lyralinux

Place the buildroot gz file you downloaded in the lyralinux folder and extract it.

> tar -xvzf  picocalc_luckfox_lyra_2025_04_15_arm-buildroot-linux-gnueabihf_sdk-buildroot.tar.gz
>
> cd arm-buildroot-linux-gnueabihf_sdk-buildroot
>
> ./relocate-sdk.sh
>
> cd ..
>
> source arm-buildroot-linux-gnueabihf_sdk-buildroot/environment-setup

This last command will need to be ran each time you open a new terminal to use the buildroot. It sets all the environment variables needed to compile programs.

Now, download the tv folder, make sure both the Makefile and tv.c are in the folder.

> cd tv

This is a very simple text viewing app that I wrote as part of an ebook reader. This program does not really need a Makefile, but I have provided it as a template you can use for other programs. If you have a look at it, the CC and SYSROOT variables are very important for making sure your system uses the correct compiler and libraries when building. When trying to compile a program you downloaded from the internet, open the Makefile and have a look at it and change the CC and SYSROOT variables to match the ones in mine and if SYSROOT is not there at all, you will need to add it. Once that is done, just type make.

> make

The tv program should compile with no errors. Other programs may give you warnings and such, but as long as it does not fail to build, you should be fine. The next thing I do is check to make sure it did not build using the compiler or libraries on your host machine. To do this us ldd, like this.

> ldd tv

This will check the program for its dependencies. If things went correctly, the output will read "not a dynamic executable", if it outputs a list of dependencies, something went wrong and you should begin again. If all went well, copy the program to your SDcard or transfer it over using scp and give it a try.

Many program Makefiles have a "make install" option, if this is the case, copy the whole folder over to the SDcard and then when you get to the PicoCalc, run the final "make install" on the PicoCalc so everything is put into the correct place.

That is pretty much it.

