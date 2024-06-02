import datetime
import json
import subprocess
import os
from collections import defaultdict
from configparser import ConfigParser

CONFIG = ConfigParser()
CONFIG.read(os.path.expanduser("~/.config/kitty/tab_bar.ini"))

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer, get_options
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
        padding = screen.columns - screen.cursor.x - sum(len(" ".join([c.get("icon", ""), c["text"]])) + 2 for c in cells)
        if padding >= 0:
            break
        cells = cells[1:]

    if padding: screen.draw(" " * padding)

    for c in cells:
        screen.cursor.bg = default_bg
        icon = c.get("icon")
        if icon:
            fg = to_color(c.get("color")) if c.get("color") else tab_fg
            screen.cursor.fg = as_rgb(int(fg))
            screen.draw(f" {icon} ")
        screen.cursor.fg = tab_fg
        text = c["text"]
        screen.draw(f"{text} ")


def create_cells():
    cells = [
        get_todo(),
        # get_work_email() if datetime.date.today().weekday()<5 else None,
        # get_personal_email(),
        get_time(),
        get_date(),
    ]
    return [c for c in cells if c is not None]

def get_time():
    now = datetime.datetime.now().strftime("%H:%M")
    return { "icon": " ", "color": "#669bbc", "text": now }

def get_date():
    today = datetime.date.today()
    if today.weekday() < 5:
        return { "icon": "󰃵 ", "color": "#2a9d8f", "text": today.strftime("%b %d") }
    else:
        return { "icon": "󰧓 ", "color": "#f2e8cf", "text": today.strftime("%b %d") }

def get_todo():
    out = subprocess.getoutput(CONFIG['todo']['command'])
    if len(out) > 0:
        return { "icon": " ", "color": "#d62828", "text": out }
    else:
        return None

def get_work_email():
    out = subprocess.getoutput(CONFIG['work_email']['command'])
    if out != '0':
        return { "icon": "󰻨 ", "color": "#e76f51", "text": out }
    else:
        return None

def get_personal_email():
    out = subprocess.getoutput(CONFIG['personal_email']['command'])
    if out != '0':
        return { "icon": "󰇰 ", "color": "#a98467", "text": out }
    else:
        return None

def _redraw_tab_bar(timer_id):
    for tm in get_boss().all_tab_managers:
        tm.mark_tab_bar_dirty()
