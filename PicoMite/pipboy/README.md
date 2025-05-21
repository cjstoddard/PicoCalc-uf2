# PIP OS for the PicoCalc

The idea for this program came from a cosplay prop I made for my wife a few years ago. Keep in mind, this is not designed to be a well thought out and easy to use UI. It is meant to emulate something designed in the Fallout world, which means it is not well thought out, often breaks, and usablity was not a concern. You can move through the screens with the left and right arrow keys, you can jump to screens using F1 - F4, and F5 exits the program.

STAT:

This screen gives youo some basic information about the PicoClac, battery percentage, free memory, IP Address and free spsce on the SD card. Please note that when the program first starts up after a reboot, it may take several seconds to finish, this is because it is determining the free space of the SD Card. 

INV:

This simply displays the contents of a file named edit.txt. This file can contain anything you want, and can be edited by pressing ctrl-e. This invokes pipedit.bas, which is a crude text editor, once you make the changes you want, ctrl-s saves the file and ctrl-q or ESC exits the program and puts you back in pipboy.bas. Please don't try to use pipedit for anything serious, and if you do, don't ask me for help with it, I will just tell you to use the PicoMite built in editor.

DATA:

This does nothing at the moment. I am taking ideas.

RADIO:

This is a crude MP3 player, it is hard coded to play specific files. The music in the folder are placeholder songs. On my PicoCalc I used music I got from Youtube, see below under Music. F6 - F9 lets you choose which MP3 to play, the keys used to play, stop, pause and resume are on the screen. If you must know, I chose those keys because they are the keybindings for cmus, an mp3 player I frequently us.

Music:

If you are looking for some Fallout appropriate music for your Pipboy, these 4 Youtube videos will give you almost 10 hours of music.

[Appalachia Radio](https://www.youtube.com/watch?v=FHF6q1mBiFs)

[Diamond City Radio](https://www.youtube.com/watch?v=Yy9La6YXNqI)

[Galaxy News Radio](https://www.youtube.com/watch?v=LxM7soNJC1A)

[Wastelanders Radio](https://www.youtube.com/watch?v=yNOj5sD570I)

In Linux, the audio of these videos can be downloaded as opus files and then converted to mp3's with the following commands;

> sudo apt install yt-dlp ffmpeg
>
> yt-dlp -x --audio-quality 0 URL
>
> ffmpeg -i Filename.opus -ab 320k -map_metadata 0:s:a:0 -id3v2_version 3 Filename.mp3

Disclaimer: This software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a paticular purpose and nonifringment. In no event shall the author or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
