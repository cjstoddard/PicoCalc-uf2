# If you do not have a Pico W/2W or you don't want
# the PicoCalc to connect to your Wifi at boot,
# go to the bottom and cooment out the last line
# like this;
# #safe_connect_wifi(WIFI_SSID, WIFI_PASSWORD)

import machine
import sdcard
import os
import network
import time

# --- SETTINGS ---
WIFI_SSID = "SSID"
WIFI_PASSWORD = "Password"
WIFI_TIMEOUT = 10  # seconds to wait before giving up
# ----------------

def safe_mount_sdcard():
    try:
        spi = machine.SPI(0,
            baudrate=1_000_000,
            polarity=0,
            phase=0,
            sck=machine.Pin(18),
            mosi=machine.Pin(19),
            miso=machine.Pin(16)
        )
        sd = sdcard.SDCard(spi, machine.Pin(17))  # CS pin
        vfs = os.VfsFat(sd)
        os.mount(vfs, "/sd")
        print("✅ SD card mounted at /sd")
    except Exception as e:
        print("⚠️ Could not mount SD card:", e)

def safe_connect_wifi(ssid, password, timeout=WIFI_TIMEOUT):
    try:
        wlan = network.WLAN(network.STA_IF)
        wlan.active(True)

        if not wlan.isconnected():
            print(f"🌐 Connecting to WiFi '{ssid}'...")
            wlan.connect(ssid, password)

            start_time = time.time()
            while not wlan.isconnected():
                if time.time() - start_time > timeout:
                    raise RuntimeError("WiFi connection timeout")
                time.sleep(0.5)

        ip = wlan.ifconfig()[0]
        print(f"✅ WiFi connected! IP address: {ip}")

    except Exception as e:
        print("⚠️ Could not connect to WiFi:", e)

# --- System Setup ---
safe_mount_sdcard()
safe_connect_wifi(WIFI_SSID, WIFI_PASSWORD)
# ---------------------

