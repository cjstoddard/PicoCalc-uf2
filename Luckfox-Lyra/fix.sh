#!/bin/sh
mkdir ~/Lyra-sdk/buildroot/package/retroarch/libretro-dosboxpure
mkdir ~/Lyra-sdk/kernel-6.1/sound/pwm
cp ~/Lyra-sdk/picocalc-luckfox-lyra/src/device/rockchip/.chips/rk3506/* ~/Lyra-sdk/device/rockchip/.chips/rk3506/

# DOSBOXPURE if enabled will cause the build to fail
sed -i 's/BR2_PACKAGE_LIBRETRO_DOSBOXPURE=y/# BR2_PACKAGE_LIBRETRO_DOSBOXPURE=y/g' ~/Lyra-sdk/picocalc-luckfox-lyra/src/buildroot/configs/rockchip_rk3506_picocalc_luckfox_defconfig

# This is optional, I don't play games
sed -i 's/BR2_PACKAGE_RETROARCH=y/# BR2_PACKAGE_RETROARCH=y/g' ~/Lyra-sdk/picocalc-luckfox-lyra/src/buildroot/configs/rockchip_rk3506_picocalc_luckfox_defconfig
