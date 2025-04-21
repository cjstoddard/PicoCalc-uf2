# PicoCalc-uf2

I compiled all the uf2 files from the PicoCalc github so you don't have to. ~~I do not have a PicoCalc yet, so if you have trouble with any of these, open an issue on it and let me know.~~ The uf2 images are in the uf2 folder.

I have started work on updating some other programs I have for the PicoCalc. ~~These programs are not functional yet, since I do not yet have a PicoCalc, I have no way to test them yet. I have not adjusted for screen size or pins for the sensors.~~ I have now acquired a PicoCalc and I have verified these programs do run properly on the device, except PicoCalc-dht22-2.bas, which is showing a corrupted screen.

Update 4-4-2025
I added an updated version of Hamurabi.bas.

Update 4-8-2025
Picocalc-dht22.bas works now. Picocalc-dht22-2.bas works, but the gauges do not render properly, I suspect this is a bug in the PicoCalc version of PicoMite for the pico 2. ~~I have not tested a bme280 yet, Picocalc-bme280.bas may still not work.~~

Update 4-9-2025
I removed picocalc-bme280.bas, there were too many things that turned out to be problematic with the way the PicoCalc is configured. The program will require a complete rewrite. One thing I did find out though is the keyboard is on I2C2, so any device you want to connect will need to be on the first I2C channel.

Update 4-10-2025
I added Pico-ed.bas. This is a crude text line editor that handles 20 lines. This can be changed, but 20 lines works best for the PicoCalc. I have no idea why someone would use this, but since someone was making an MP3 player, I figured a text editor was not an entirely stupid idea. Writing a full screen text editor would be impractical in PicoMite Basic and if you need one, the built in editor is perfectly functional.

Update 4-12-2025
I added an updated version of lunar.bas, a Lunar Lander game.

Update 4-16-2025
Added RndDungeon.bas, this is a dumb little dungeon crawling text adventure I originally wrote multiple decades ago. This is not the original code, I spent a couple of hours updating it, removing line numbers and changing variable names from things like a$ to something more meaningful like action$, but the core functionality is all the same. Its replay value in its current form is fairly low, but my friends and I expanded it by adding random weird things to it. I can not post those versions of the game, because first, I no longer have them, but also we were teenaged boys and so its not hard to guess the ultra violent, crude and often sexual content of those later versions. As I recall the last version exceeded a thousand lines of code. View this code not as a fully playable game, but rather a framework for building something more intersting.

Update 4-20-2025
I found a slightly newer version of RndDungeon.bas which included a trap mechanic.

Disclaimer: This software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a paticular purpose and nonifringment. In no event shall the author or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
