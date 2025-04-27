# MicroPython Projects

Update 4-26-2025
I ported Hamurabi to MicroPython, mostly just to practice MicroPython. I added my boot.py and main.py files as well, along with the module files, placed properly in a lib folder. I found the defaults were not working for me for whatever reason. If you find your PicoCalc is not loading properly using the standard setup, try removing evrything from the Pico and upload the contents of the Boot Files folder to your Pico and see if it works. Netchk.py is a simple program to check to make sure the PicoCalc has mounted the SD card and connected to the Wifi after booting. To run a program, use the following commands;

> from picocalc_system import run
> run("test.py")

Or to run a program from the SD Card, use this;

> run("/sd/test.py")

Disclaimer: This software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a paticular purpose and nonifringment. In no event shall the author or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
