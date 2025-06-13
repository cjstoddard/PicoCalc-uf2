# DS3231 Realtime Clock

Setrtc.bas and settime.bas are programs to manage a DS3231 RTC mounted externally on a PicoCalc.

The problem: I did not want to solder an RTC internally in my PicoCalc. I am perfectly capable of doing it, I just did not want to. To be honest, I mostly use Webmite, so I can easily sync time to an NTP server. However occassionally I do use RTC's for various projects. The first issue I had is PicoMite Basic only lets you set one I2C setting in the options and that was taken up by the PicoCalc keyboard. Because of this, the easy way of setting up an RTC is not availble to us. The second issue was the keyboard is set to I2C2, so we have to use GP4 for SDA and GP5 for SCL, which is not that big of a problem, it was just confusing at first.

Once wired up, we then need two programs, the first one is setrtc.bas, this lets you set the date and time on the RTC, you should only have to do this once, unless you have to change the battery out. The second program, settime.bas sets the PicoCalc time by retrieving the date and time from the RTC. This program should be autorun at boot time.

Most of this code is not original to me, so credit goes to;

rlauzon

https://github.com/rlauzon54/PicoCalcBasic/blob/main/onboot.bas

tassyJim

https://www.thebackshed.com/forum/ViewTopic.php?TID=17833&PID=236974#236974

Disclaimer: This software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a paticular purpose and nonifringment. In no event shall the author or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.
