import network
import ntptime

wlan = network.WLAN(network.STA_IF)  # STA_IF = station interface (client mode)
UTF_OFFSET = -5 * 60 * 60 # Change -5 for your timezone

if wlan.isconnected():
    ip_info = wlan.ifconfig()
    print("My IP address is:", ip_info[0])  # [0] is the IP address
    ntptime.settime()
    now = time.localtime(time.time() + UTF_OFFSET)
    print("\n")
    print("Date: {}/{}/{}".format(now[1], now[2], now[0]))
    print("Time: {}:{}".format(now[3], now[4]))
else:
    print("Not connected to WiFi.")

print("\n Files on the SD Card.")
print(os.listdir('/sd'))
