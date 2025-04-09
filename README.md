# PicoCalc-uf2

I compiled all the uf2 files from the PicoCalc github so you don't have to. I do not have a PicoCalc yet, so if you have trouble with any of these, open an issue on it and let me know. These uf2 images are in the uf2 folder.

I have started work on updating some other programs I have for the PicoCalc. These programs are not functional yet, since I do not yet have a PicoCalc, I have no way to test them yet. I have not adjusted for screen size or pins for the sensors.

Update 4-4-2025
I added an updated version of Hamurabi.bas.

Update 4-8-2025
Picocalc-dht22.bas works now. Picocalc-dht22-2.bas works, but the gauges do not render properly, I suspect this is a bug in the PicoCalc version of PicoMite for the pico 2. I have not tested a bme280 yet, Picocalc-bme280.bas may still not work.

Update 4-9-2025
I removed icocalc-bme280.bas, there were too many things that turned out to be problematic with the way the PicoCalc is configured. The program will require a complete rewrite. One thing I did find out though is the keyboard is on I2C2, so any device you want to connect will need to be on the first I2C channel.

Disclaimer: This software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a paticular purpose and nonifringment. In no event shall the author or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
