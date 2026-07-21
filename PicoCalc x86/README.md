# PicoCalc x86

## Links

The project

https://github.com/shtirlic/picocalc_x86

MS-DOS 6.22 Full install (You will need 7zip to extract the images)

https://winworldpc.com/download/c38fc38d-68c2-bbe2-80a6-4b11c3a4c2ac

DOSBox-x

https://dosbox-x.com/

## Build Image instructions

Download and install DOSBox-X. You can use one of the other versions of DOSBox, but I have found this one to be functionally the best. 

Next download the MD-DOS 6.22 disk set and extract the images from the 7z file. 

Make a new folder somehwere easy for you to find, name it DOSBox-hd. The copy the three disk images you extracted into this folder.

Run DOSBox, from the dropdown menu, click on "Drive", go down to "D", and choose "Mount Folder as Hard Drive". Then go choose the DOSBox-hd folder you just made. It should now be the D: drive in DOSBox. Switch drives to D:, and type dir, you should see the disk images files.

> d:

> dir

Still in the DOS prompt, you want to make your new disk image with the following command;

> IMGMAKE hd.img -t hd -size 512

Once it is done, you must now mount it as the C: drive;

> IMGMOUNT C hd.img

Finally, we want to boot to the first image disk;

> BOOT DISK1.IMG

Once the first disk is done, from the drop down menu, select "DOS" followed by "Swap floppy drive", then choose DISK2.IMG, and once it is done, do the same for DISK3.IMG. After that DOSBox will want to reboot.

At this point, if your operating system supports mount disk images, I know Mac OS and Linux does. You can mount the hd.img file and copy my ready made config.sys and autoexec.bat files. This is also a good time to copy and programs you want into your image. Umount the image, then copy you hd.img file to the x86 folder on your SD, insert it into your Picocalc, and you should be ready to go.

In the image folder there is a premade image, if you want to skip some steps.