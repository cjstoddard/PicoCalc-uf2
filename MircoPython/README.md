# MicroPython Projects

Update 5-7-2025
I have abondoned using Micropython on my PicoCalc and have instead went the route of installing a Lyra board in to. I deleted Tomato and Face-Monitor as neither ever worked the way I wanted them to. The others I will leave here until I get tired of looking at them.

Update 5-2-2025
Uploaded chatgpt.py and secrets.py. The Youtuber sn0ren did a video covering the PicoCalc and one of the things he talked about was using [MicroPython to access ChatGPT](https://www.youtube.com/watch?v=-d8Hj0SEFR0). He however never shows us the code. He said he went to ChatGPT and asked it to write the program for him, so I did the same thing. Yes, this program was written enirely by ChatGPT. You will need a Raspberry Pi Pico W or a 2W for this program to run. You will also need to get an API key from OpenAI, it will cost you a couple dollars to load your account, but $10 will be more than enough for this program to run for a long time. Once you have an API key, open the secrets.py file and fill in your Wifi SSID, password and API key. You should be able to run the progam and talk to ChatGPT and get responses.

Update 4-29-2025
I added Tomato.py and face_monitor.py. [Tomato is an idea I came up with](https://github.com/cjstoddard/Tomato) for another project. The idea was to emulate the Tomato Computer used by RadicalEdward in the Cowboy Bebop series. This a scaled down version of that project, using ASCI emoji's instaed of images. Face_monitor.py is Tomato.py packaged up so it can be imported into other programs. Place Face_monitor.py in the folder with your program or in a lib folder and add the following to your program.

> import face_monitor
>
> face_monitor.init()
>
> while True:
>
>    face_monitor.update()
>
>    time.sleep(0.1)

Face_monitor.py uses the lower right of the screen, so plan accordingly.

I am still working on using images rather than emjois, I think it gives a more looks better RadicalEdward vibe and just looks all around better.

I have also fixed the Hamurabi.bas bug, I uploaded it, but I have not had a chance to actually test it yet.

Update 4-28-2025
I am aware of the bug in Hamurabi.bas that was rebooting the PicoCalc at the end of the game. I am fiddling with other things at the moment, I will get to it shortly. In the meantime, I changed it so it just errors out without rebboting the device.

I updated main.py to include the line "from picocalc_system import run" so you can use the run command without typing in the import command everytime the PicoCalc boots up.

I updated Netchk.py to set the device time from the internet.

Update 4-26-2025
I ported Hamurabi to MicroPython, mostly just to practice MicroPython. I added my boot.py and main.py files as well, along with the module files, placed properly in a lib folder. I found the defaults were not working for me for whatever reason. If you find your PicoCalc is not loading properly using the standard setup, try removing evrything from the Pico and upload the contents of the Boot Files folder to your Pico and see if it works. Netchk.py is a simple program to check to make sure the PicoCalc has mounted the SD card and connected to the Wifi after booting. To run a program, use the following commands;

> ~~from picocalc_system import run~~
>
> run("test.py")

Or to run a program from the SD Card, use this;

> run("/sd/test.py")

Disclaimer: This software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a paticular purpose and nonifringment. In no event shall the author or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
