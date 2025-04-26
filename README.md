# PicoCalc-uf2

I compiled all the uf2 files from the PicoCalc github so you don't have to. ~~I do not have a PicoCalc yet, so if you have trouble with any of these, open an issue on it and let me know.~~ The uf2 images are in the uf2 folder.

I have started work on updating some other programs I have for the PicoCalc. ~~These programs are not functional yet, since I do not yet have a PicoCalc, I have no way to test them yet. I have not adjusted for screen size or pins for the sensors.~~ I have now acquired a PicoCalc and I have verified these programs do run properly on the device, except PicoCalc-dht22-2.bas, which is showing a corrupted screen.

Update 4-26-2025
I now have two PicoCalc devices. I tried putting a LuckFox Lyra into it and seeing how Linux felt on it. I got the results I expected, the Lyra plus PicoCalc configuration is too underpowered for reasonable use as a Linux device, even when just using the command line. I do not recomend this configuration, you are better off getting a Hackberry Pi Zero.

So, I swapped in a Pico 2 W and flashed the firmware with MicroPython. With that, I moved all the Basic files to the PicoMite folder and added a MicroPython folder to seperate out the work I am doing on each device. I also removed the uf2 folder, I doubt anyone found it useful and frankly it was too much trouble to maintain current builds of some of those projects.

Disclaimer: This software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a paticular purpose and nonifringment. In no event shall the author or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
