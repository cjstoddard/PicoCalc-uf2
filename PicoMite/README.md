# PicoMite Basic Projects

Update 6-12-2025

Added the DS3231 folder with programs to manage a DS3231 RTC mounted externally on a PicoCalc.

Update 5-28-2025

Added tomato.bas, a better version of Picogotchi. It has assets its needs to run and has its own readme file.

Update 5-21-2025

I added pipboy.bas and supporting files. This turns your PicoClac into a fun little cosplay accessory. It has its own README file with details.

Update 4-30-2025

I added Picogotchi.bas.This is a PicoMite Basic variant of my Micropython Tomato code. I actually like the way this works better than Tomato. Picogotchi does some base line system monitoring and then displays a little face that looks around and expresses moods. The SimulateWork() function is there just to have something to do. You should replace this function with something useful.

Update 4-29-2025

I added onboot.bas, which is a simple program I run after the device is booted. It sets the date from the internet, prints the IP address and changes the default drive to the SD card. To use this program, you will need to set the Wifi options in the firmware, you will also need to change the -5 to your timezone. I don't autorun it, because most of the time it will run before the PicoCalc gets an IP address from the router.

Update 4-20-2025

I found a slightly newer version of RndDungeon.bas which included a trap mechanic.

Update 4-16-2025

Added RndDungeon.bas, this is a dumb little dungeon crawling text adventure I originally wrote multiple decades ago. This is not the original code, I spent a couple of hours updating it, removing line numbers and changing variable names from things like a$ to something more meaningful like action$, but the core functionality is all the same. Its replay value in its current form is fairly low, but my friends and I expanded it by adding random weird things to it. I can not post those versions of the game, because first, I no longer have them, but also we were teenaged boys and so its not hard to guess the ultra violent, crude and often sexual content of those later versions. As I recall the last version exceeded a thousand lines of code. View this code not as a fully playable game, but rather a framework for building something more intersting.

Update 4-12-2025

I added an updated version of lunar.bas, a Lunar Lander game.

Update 4-10-2025

I added Pico-ed.bas. This is a crude text line editor that handles 20 lines. This can be changed, but 20 lines works best for the PicoCalc. I have no idea why someone would use this, but since someone was making an MP3 player, I figured a text editor was not an entirely stupid idea. Writing a full screen text editor would be impractical in PicoMite Basic and if you need one, the built in editor is perfectly functional.

Update 4-9-2025

I removed picocalc-bme280.bas, there were too many things that turned out to be problematic with the way the PicoCalc is configured. The program will require a complete rewrite. One thing I did find out though is the keyboard is on I2C2, so any device you want to connect will need to be on the first I2C channel.

Update 4-8-2025

Picocalc-dht22.bas works now. Picocalc-dht22-2.bas works, but the gauges do not render properly, I suspect this is a bug in the PicoCalc version of PicoMite for the pico 2.

Update 4-4-2025

I added an updated version of Hamurabi.bas.

Disclaimer: This software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a paticular purpose and nonifringment. In no event shall the author or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
