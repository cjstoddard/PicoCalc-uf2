# Build you own image

This is a high level overview of building your own Linux image for a PicoCalc with the Luckfox Lyra mod. This is just enough information to get you to the point of building a basic image. All of this information is availble elsewhere, the problem is, it is spread out in different places. All I am doing here is putting all the information into one place.

The first thing you need to do is either install Ubuntu 22.04 on a computer or a Virtual Machine. I am not going go into detail on this. You have to use Ubuntu 22.04 because the build requires Python 2, which is obsolete and is not available in most newer Linux distributions. I hope at some point Luckfox fixes this, but I am not holding my breath or making any bets on it. Once you have Ubuntu 22.04 installed and updated, you will need to install some software.

> sudo apt install git ssh make gcc libssl-dev liblz4-tool expect \
> expect-dev g++ patchelf chrpath gawk texinfo chrpath diffstat \
> binfmt-support qemu-user-static live-build bison flex fakeroot cmake \
> gcc-multilib g++-multilib unzip device-tree-compiler ncurses-dev \
> libgucharmap-2-90-dev bzip2 expat gpgv2 cpp-aarch64-linux-gnu libgmp-dev \
> libmpc-dev bc python-is-python3 python2 

Then you will need to make Python2 the default Python.

> sudo ln -sf /usr/bin/python2 /usr/bin/python

Download the latest SDK from the Luckfox Google Drive.

https://drive.google.com/drive/folders/1l2ixhfw53J3eZunyvHMnw2DYViH9d8Cx

> mkdir Lyra-sdk

Copy Luckfox_Lyra_SDK_250429.tar.gz into the Lyra-sdk from wherever you downloaded it to.

> cd Lyra-sdk

> tar -xzvf Luckfox_Lyra_SDK_250429.tar.gz

> .repo/repo/repo sync -l

> git clone https://github.com/nekocharm/picocalc-luckfox-lyra.git

The prepare.sh script does a pretty good job of putting things in the right places, however it is not perfect, so we need to fix some problems before we run it.

> mkdir ~/Lyra-sdk/buildroot/package/retroarch/libretro-dosboxpure

> mkdir ~/Lyra-sdk/kernel-6.1/sound/pwm

> cp ~/Lyra-sdk/picocalc-luckfox-lyra/src/device/rockchip/.chips/rk3506/* ~/Lyra-sdk/device/rockchip/.chips/rk3506/

DOSBOXPURE if enabled will cause the build to fail, so you need to disable it.

> sed -i 's/BR2_PACKAGE_LIBRETRO_DOSBOXPURE=y/# BR2_PACKAGE_LIBRETRO_DOSBOXPURE=y/g' ~/Lyra-sdk/picocalc-luckfox-lyra/src/buildroot/configs/rockchip_rk3506_picocalc_luckfox_defconfig

This is optional, I don't play games so I disbale RETROARCH. If you want it, skip this step.

> sed -i 's/BR2_PACKAGE_RETROARCH=y/# BR2_PACKAGE_RETROARCH=y/g' ~/Lyra-sdk/picocalc-luckfox-lyra/src/buildroot/configs/rockchip_rk3506_picocalc_luckfox_defconfig

This is a good time to have a look at the packages you want to be installed, edit this file and comment out anything you don't want. Please leave DOSBOXPURE commented out, the build will fail with it enabled.

> nano ~/Lyra-sdk/picocalc-luckfox-lyra/src/buildroot/configs/rockchip_rk3506_picocalc_luckfox_defconfig

Once you are done with that save and exit the file. Now we are ready to run the prepare.sh script to get the drivers in place.

> cd picocalc-luckfox-lyra

> ./prepare.sh

> cd ..

Now you are ready to build the image. When you run the next command choose number 7. This finishes the preperations for the image build.

> ./build.sh lunch

And finally, we build the image.

> ./build.sh

Good luck!