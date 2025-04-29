# face_monitor.py
# Code by Chris Stoddard

import time
import random
import gc
import machine
from picocalc import PicoDisplay

# Screen setup
SCREEN_WIDTH = 320
SCREEN_HEIGHT = 320

# Display and colors
screen = None
COLOR_WHITE = 0xFFFF
COLOR_BLACK = 0x0000

# Moods
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

look_faces = ["LOOK_L", "LOOK_R", "LOOK_L_HAPPY", "LOOK_R_HAPPY"]
cool_moods = ["COOL", "HAPPY", "SMART"]
high_temp_moods = ["ANGRY", "INTENSE", "DEBUG"]
low_memory_moods = ["SAD", "BROKEN", "DEMOTIVATED"]
normal_moods = ["FRIEND", "EXCITED", "MOTIVATED", "GRATEFUL"]

# Internal state
_scroll_message = "All Systems Normal"
_last_face_update = 0
_idle_timer_start = 0
_last_face_name = "AWAKE"

def _draw_face(top_line, bottom_line):
    margin = 5
    face_width = max(len(top_line), len(bottom_line)) * 6
    face_height = 16

    start_x = SCREEN_WIDTH - face_width - margin
    start_y = SCREEN_HEIGHT - face_height - margin - 16

    if start_x < 0:
        start_x = 0
    if start_y < 0:
        start_y = 0

    for y in range(start_y, start_y + face_height):
        for x in range(start_x, SCREEN_WIDTH):
            screen.pixel(x, y, COLOR_BLACK)

    screen.text(top_line, start_x, start_y, COLOR_WHITE)
    screen.text(bottom_line, start_x, start_y + 8, COLOR_WHITE)
    screen.show()

def _clear_scroll_area():
    for y in range(SCREEN_HEIGHT - 16, SCREEN_HEIGHT):
        for x in range(0, SCREEN_WIDTH):
            screen.pixel(x, y, COLOR_BLACK)

def _scroll_text():
    _clear_scroll_area()
    full_msg = _scroll_message + "    "
    pixel_per_char = 6

    for shift in range(len(full_msg) * pixel_per_char):
        _clear_scroll_area()
        text_x = SCREEN_WIDTH - shift
        text_y = SCREEN_HEIGHT - 12

        for i, char in enumerate(full_msg):
            x = text_x + i * pixel_per_char
            if 0 <= x < SCREEN_WIDTH:
                screen.text(char, x, text_y, COLOR_WHITE)

        screen.show()
        time.sleep(0.02)

def _read_cpu_temperature():
    sensor_temp = machine.ADC(4)
    reading = sensor_temp.read_u16() * (3.3 / 65535)
    return 27 - (reading - 0.706) / 0.001721

def _free_memory():
    gc.collect()
    return gc.mem_free() / 1024

def init():
    """Initialize face monitor system."""
    global screen, _idle_timer_start, _last_face_update
    screen = PicoDisplay(SCREEN_WIDTH, SCREEN_HEIGHT, color_type=2)
    screen.stopRefresh()
    _idle_timer_start = time.time()
    _last_face_update = time.time()

    show_face("AWAKE")

def show_face(name):
    """Manually show a specific face."""
    global _last_face_name
    if name in moods:
        top_line, bottom_line = moods[name]
        _draw_face(top_line, bottom_line)
        _last_face_name = name

def update():
    """Call periodically to refresh the face and scroll the text."""
    global _last_face_update, _scroll_message

    cpu_temp = _read_cpu_temperature()
    free_ram = _free_memory()

    if cpu_temp > 60:
        mood_name = random.choice(high_temp_moods)
        _scroll_message = "High Temp!"
    elif free_ram < 20:
        mood_name = random.choice(low_memory_moods)
        _scroll_message = "Low Memory!"
    else:
        mood_name = random.choice(normal_moods)
        _scroll_message = "All Systems Normal"

    now = time.time()
    if now - _last_face_update > 5:
        # Every 5 seconds, look around
        look = random.choice(look_faces)
        top_line, bottom_line = moods[look]
        _draw_face(top_line, bottom_line)
        _last_face_update = now
    else:
        # Face remains the same otherwise
        top_line, bottom_line = moods[_last_face_name]
        _draw_face(top_line, bottom_line)

    _scroll_text()
