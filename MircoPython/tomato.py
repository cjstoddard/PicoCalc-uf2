# tomato.py
# Code by Chris Stoddard

import machine
import os
import time
import gc
import sys
import random
from picocalc import PicoDisplay

# Screen size
SCREEN_WIDTH = 320
SCREEN_HEIGHT = 320

# Initialize display
screen = PicoDisplay(SCREEN_WIDTH, SCREEN_HEIGHT, color_type=2)
screen.stopRefresh()

# Colors
COLOR_WHITE = 0xFFFF
COLOR_BLACK = 0x0000

# Moods mapping (two-line faces)
moods = {
    "LOOK_R": ("( o_o )", "  (   >)"),
    "LOOK_L": ("( o_o )", "(<    )"),
    "LOOK_R_HAPPY": ("( ^_^)", "  (   >)"),
    "LOOK_L_HAPPY": ("(^_^ )", "(<    )"),
    "SLEEP": ("( -_- )", "  zzz"),
    "SLEEP2": ("( =_= )", "  zZz"),
    "AWAKE": ("( o_o )", " /|\\ "),
    "BORED": ("( -__- )", "  ..."),
    "INTENSE": ("( o_O )", "(! !)"),
    "COOL": ("( B_o )", "(⌐■_■)"),
    "HAPPY": ("(^_^)/", " / | \\ "),
    "GRATEFUL": ("(^.^)/", "  \\|/"),
    "EXCITED": ("(*_*)/", "\\o o/"),
    "MOTIVATED": ("(o^_^o)", "/\\ /\\/\\"),
    "DEMOTIVATED": ("( ._. )", " ( - )"),
    "SMART": ("( o_o)b", "  /|\\ "),
    "LONELY": ("( ._. )", " (    )"),
    "SAD": ("( ;_; )", " (   )"),
    "ANGRY": ("( >_< )", " /! !\\ "),
    "FRIEND": ("(^_^)♥", " /   \\"),
    "BROKEN": ("( 'o' )", "  ( x )"),
    "DEBUG": ("( x_x )", " [##]"),
    "UPLOAD": ("( 1_0 )", " / ^ \\ "),
    "UPLOAD1": ("( 1_1 )", " (v)"),
    "UPLOAD2": ("( 0_1 )", " (^)"),
}

# Categories for random looking around
look_faces = ["LOOK_L", "LOOK_R", "LOOK_L_HAPPY", "LOOK_R_HAPPY"]

cool_moods = ["COOL", "HAPPY", "SMART"]
high_temp_moods = ["ANGRY", "INTENSE", "DEBUG"]
low_memory_moods = ["SAD", "BROKEN", "DEMOTIVATED"]
normal_moods = ["FRIEND", "EXCITED", "MOTIVATED", "GRATEFUL"]

# Safe display of a two-line face, shifted up two lines
def display_mood_bottom_right(top_line, bottom_line):
    margin = 5
    face_width = max(len(top_line), len(bottom_line)) * 6
    face_height = 16  # 2 lines of 8px each

    # Start X/Y, shifted up by 16 pixels
    start_x = SCREEN_WIDTH - face_width - margin
    start_y = SCREEN_HEIGHT - face_height - margin - 16

    # Clamp to screen
    if start_x < 0:
        start_x = 0
    if start_y < 0:
        start_y = 0

    # Clear previous face area
    for y in range(start_y, start_y + face_height):
        for x in range(start_x, SCREEN_WIDTH):
            screen.pixel(x, y, COLOR_BLACK)

    # Draw the face
    screen.text(top_line, start_x, start_y, COLOR_WHITE)
    screen.text(bottom_line, start_x, start_y + 8, COLOR_WHITE)
    screen.show()

# Draw black box at the very bottom for scrolling text
def clear_scroll_area():
    for y in range(SCREEN_HEIGHT - 16, SCREEN_HEIGHT):
        for x in range(0, SCREEN_WIDTH):
            screen.pixel(x, y, COLOR_BLACK)

# Scroll a message across the bottom 2 lines
def scroll_text(msg):
    clear_scroll_area()
    full_msg = msg + "    "  # Space padding
    pixel_per_char = 6

    for shift in range(len(full_msg) * pixel_per_char):
        clear_scroll_area()
        text_x = SCREEN_WIDTH - shift
        text_y = SCREEN_HEIGHT - 12  # Middle of bottom 2 lines

        for i, char in enumerate(full_msg):
            x = text_x + i * pixel_per_char
            if 0 <= x < SCREEN_WIDTH:
                screen.text(char, x, text_y, COLOR_WHITE)

        screen.show()
        time.sleep(0.02)  # Smooth fast scroll

# CPU temperature read
def read_cpu_temperature():
    sensor_temp = machine.ADC(4)
    reading = sensor_temp.read_u16() * (3.3 / 65535)
    temperature_c = 27 - (reading - 0.706) / 0.001721
    return temperature_c

# Free RAM check
def free_memory():
    gc.collect()
    return gc.mem_free() / 1024  # KB

# Main program loop
def main():
    try:
        # Startup
        awake_top, awake_bottom = moods["AWAKE"]
        display_mood_bottom_right(awake_top, awake_bottom)
        time.sleep(1.5)

        while True:
            cpu_temp = read_cpu_temperature()
            free_ram = free_memory()

            print(f"Temp: {cpu_temp:.1f}C, Free RAM: {free_ram:.1f} KB")

            # Determine mood based on system status
            if cpu_temp > 60:
                mood_name = random.choice(high_temp_moods)
                scroll_message = "High Temp!"
            elif free_ram < 20:
                mood_name = random.choice(low_memory_moods)
                scroll_message = "Low Memory!"
            else:
                mood_name = random.choice(normal_moods)
                scroll_message = "All Systems Normal"

            # Display base mood immediately
            base_top, base_bottom = moods[mood_name]
            display_mood_bottom_right(base_top, base_bottom)

            # Scroll text while waiting 30 seconds
            start_time = time.time()
            while time.time() - start_time < 30:
                scroll_text(scroll_message)

                # Every 5 seconds, random look-around face
                if int(time.time() - start_time) % 5 == 0:
                    look_name = random.choice(look_faces)
                    look_top, look_bottom = moods[look_name]
                    display_mood_bottom_right(look_top, look_bottom)

    except KeyboardInterrupt:
        print("Program stopped by user")
        sys.exit()
    except Exception as e:
        print(f"Error: {e}")
        sys.exit()

if __name__ == "__main__":
    main()

