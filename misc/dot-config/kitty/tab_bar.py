import datetime
import subprocess
import os
import time
from configparser import ConfigParser

CONFIG = ConfigParser()
CONFIG.read(os.path.expanduser("~/.config/kitty/tab_bar.ini"))

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer
from kitty.rgb import to_color
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    TabBarData,
    as_rgb,
    draw_attributed_string,
    draw_tab_with_powerline,
)

timer_id = None

# Cache for expensive subprocess calls with lazy refresh
_cached_data = {
    'alarm': {'value': None, 'timestamp': 0, 'ttl': 60},
    'email_work': {'value': None, 'timestamp': 0, 'ttl': 300},
    'email_gmail': {'value': None, 'timestamp': 0, 'ttl': 300},
    'email_icloud': {'value': None, 'timestamp': 0, 'ttl': 300},
}

def _is_stale(key):
    """Check if cache entry is stale or empty."""
    entry = _cached_data[key]
    return entry['value'] is None or (time.time() - entry['timestamp']) > entry['ttl']

def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global timer_id

    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, 2.0, True)
    draw_tab_with_powerline(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )
    if is_last: draw_right_status(draw_data, screen)
    return screen.cursor.x

def draw_right_status(draw_data: DrawData, screen: Screen) -> None:
    # The tabs may have left some formats enabled. Disable them now.
    draw_attributed_string(Formatter.reset, screen)
    tab_bg = as_rgb(int(draw_data.inactive_bg))
    tab_fg = as_rgb(int(draw_data.inactive_fg))
    default_bg = as_rgb(int(draw_data.default_bg))

    cells = create_cells()

    # Drop cells that wont fit
    while True:
        if not cells:
            return
        padding = screen.columns - screen.cursor.x - sum(len(" ".join([c.get("icon", ""), c.get("text", "")])) + 2 for c in cells)
        if padding >= 0:
            break
        cells = cells[1:]

    if padding: screen.draw(" " * padding)

    for c in cells:
        icon = c.get("icon")
        screen.draw(" ")
        if icon:
            fg = to_color(c.get("color")) if c.get("color") else tab_fg
            screen.cursor.blink = c.get("blink")
            if not c.get("inverse"):
                screen.cursor.bg = default_bg
                screen.cursor.fg = as_rgb(int(fg))
            else:
                screen.cursor.fg = default_bg
                screen.cursor.bg = as_rgb(int(fg))
            screen.draw(icon)
        screen.cursor.bg = default_bg
        screen.draw(" ")
        screen.cursor.fg = as_rgb(int(to_color("#778da9")))
        screen.draw(f"{c.get("text", "")} ")

def create_cells():
    cells = [
        # get_todo(),
        get_email('work', '#a98467'),
        get_email('gmail'),
        get_email('icloud'),
        get_alarm(),
        get_time(),
        get_date(),
    ]
    return [c for c in cells if c is not None]

def get_alarm():
    if _is_stale('alarm'):
        add_timer(_refresh_alarm, 0.1, False)
    return _cached_data['alarm']['value']

def _refresh_alarm(timer_id):
    """Background fetch for alarm data."""
    out = subprocess.getoutput(CONFIG['alarm']['command'])
    if out > "00:30":
        result = { "icon": " ", "color": "#06d6a0" , "text": out }
    elif out > "00:05":
        result = { "icon": " ", "color": "#ffd166" , "text": out, "inverse": True }
    elif len(out) > 0:
        result = { "icon": "󰺁 ", "color": "#ef476f" , "text": out, "inverse": True, "blink": True }
    else:
        result = None
    _cached_data['alarm']['value'] = result
    _cached_data['alarm']['timestamp'] = time.time()
    _redraw_tab_bar(None)

def get_time():
    now = datetime.datetime.now().strftime("%H:%M")
    out = subprocess.getoutput(CONFIG['todo']['command'])
    return { "icon": " ", "color": "#669bbc", "text": now }

def get_date():
    today = datetime.date.today()
    if today.weekday() < 5:
        return { "icon": "󰃵 ", "color": "#2a9d8f", "text": today.strftime("%b %d") }
    else:
        return { "icon": "󰧓 ", "color": "#f2e8cf", "text": today.strftime("%b %d") }

def get_email(type, color = "#e76f51"):
    cache_key = f'email_{type}'
    if _is_stale(cache_key):
        add_timer(lambda t: _refresh_email(t, type, color), 0.1, False)
    return _cached_data[cache_key]['value']

def _refresh_email(timer_id, type, color):
    """Background fetch for email count."""
    config = CONFIG[f'mail.{type}']
    out = subprocess.getoutput(config['command'])
    if out != '0':
        result = { "icon": config['icon'] + " ", "color": color, "text": out }
    else:
        result = None
    cache_key = f'email_{type}'
    _cached_data[cache_key]['value'] = result
    _cached_data[cache_key]['timestamp'] = time.time()
    _redraw_tab_bar(None)

def _redraw_tab_bar(timer_id):
    for tm in get_boss().all_tab_managers:
        tm.mark_tab_bar_dirty()
