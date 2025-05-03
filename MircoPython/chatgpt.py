import network
import urequests
import time
import json
from secrets import WIFI_SSID, WIFI_PASSWORD, OPENAI_API_KEY
from picocalc import PicoDisplay
from picocalc import PicoKeyboard

def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    if not wlan.isconnected():
        print("Connecting to Wi-Fi...")
        wlan.connect(WIFI_SSID, WIFI_PASSWORD)
        while not wlan.isconnected():
            time.sleep(0.5)
    print("Connected to Wi-Fi:", wlan.ifconfig())

def chat_with_gpt(prompt):
    url = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {OPENAI_API_KEY}"
    }
    data = {
        "model": "gpt-3.5-turbo",
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.5,
        "max_tokens": 100
    }

    try:
        response = urequests.post(url, headers=headers, data=json.dumps(data))
        result = response.json()
        response.close()
        return result["choices"][0]["message"]["content"]
    except Exception as e:
        return f"Error: {e}"

# --- MAIN PROGRAM ---

connect_wifi()

while True:
    try:
        prompt = input("You: ")
        if prompt.strip().lower() in ("exit", "quit"):
            print("Goodbye!")
            break

        print("Sending to ChatGPT...")
        reply = chat_with_gpt(prompt)
        print("ChatGPT:", reply)
    except KeyboardInterrupt:
        print("\nSession ended.")
        break

