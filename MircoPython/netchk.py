import network

wlan = network.WLAN(network.STA_IF)  # STA_IF = station interface (client mode)

if wlan.isconnected():
    ip_info = wlan.ifconfig()
    print("My IP address is:", ip_info[0])  # [0] is the IP address
else:
    print("Not connected to WiFi.")

print("SD Card Listing")
print(os.listdir('/sd'))
