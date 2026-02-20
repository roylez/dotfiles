"""Custom kitty tab bar with status indicators.

Displays email counts, alarm status, time, and date in the tab bar.
Uses lazy-refresh caching to avoid blocking on subprocess calls.
"""
import datetime
import subprocess
import os
import time
from dataclasses import dataclass, field
from typing import Any
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

# ============================================================================
# Cache Entry Definition
# ============================================================================

@dataclass
class CacheEntry:
    """A cached value with timestamp-based expiration."""
    value: Any = None
    timestamp: float = 0.0
    ttl: int = 60


# ============================================================================
# Global State
# ============================================================================

timer_id = None
_cached_cells = None  # Cache for rendered cells

# Cache for expensive subprocess calls with lazy refresh
_cached_data: dict[str, CacheEntry] = {
    'alarm': CacheEntry(ttl=60),
    'email_work': CacheEntry(ttl=60),
    'email_gmail': CacheEntry(ttl=60),
    'email_icloud': CacheEntry(ttl=60),
}

def _should_refresh(key: str) -> bool:
    """Check if cache entry is stale or empty and needs refresh.

    Uses a lazy-refresh pattern: if stale, schedules a background timer
    to fetch new data, but returns current (possibly stale) value immediately.
    """
    entry = _cached_data[key]
    return entry.value is None or (time.time() - entry.timestamp) > entry.ttl

def _refresh_cached_cells(timer_id):
    """Refresh cached cells periodically."""
    global _cached_cells
    new_cells = create_cells()
    if new_cells != _cached_cells:
        _cached_cells = new_cells


# ============================================================================
# Helper Functions
# ============================================================================

def _get_config(section: str, key: str, default: str = "") -> str:
    """Safely get config value with fallback.

    Returns the config value if section and key exist, otherwise returns default.
    Prevents crashes when config sections are missing.
    """
    try:
        return CONFIG[section].get(key, default)
    except KeyError:
        return default


def _calculate_cell_width(cell: dict) -> int:
    """Calculate display width of a cell (icon + text + padding)."""
    icon_len = len(cell.get("icon", ""))
    text_len = len(cell.get("text", ""))
    return icon_len + text_len + 2  # +2 for spacing


# ============================================================================
# Drawing Functions
# ============================================================================

def _draw_right_status_cached(draw_data: DrawData, screen: Screen, cells):
    """Draw right status from cached cells."""
    draw_attributed_string(Formatter.reset, screen)
    default_bg = as_rgb(int(draw_data.default_bg))
    tab_fg = as_rgb(int(draw_data.inactive_fg))
    cells = list(cells)

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
        screen.draw(f"{c.get('text', '')} ")

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
    """Main entry point - called by kitty for each tab.

    Sets up periodic timers on first call, delegates to powerline renderer,
    and draws status indicators on the last tab.
    """
    global timer_id, _cached_cells

    if timer_id is None:
        timer_id = add_timer(_redraw_tab_bar, 2.0, True)
        add_timer(_refresh_cached_cells, 1.0, True)
    draw_tab_with_powerline(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )
    if is_last and _cached_cells:
        _draw_right_status_cached(draw_data, screen, _cached_cells)
    return screen.cursor.x


# ============================================================================
# Data Provider Functions
# ============================================================================

def create_cells() -> list[dict]:
    """Create list of status cells to display in the tab bar."""
    cells = [
        get_email('work', '#a98467'),
        get_email('gmail'),
        get_email('icloud'),
        get_alarm(),
        get_time(),
        get_date(),
    ]
    return [c for c in cells if c is not None]


def get_alarm() -> dict | None:
    """Get alarm status with lazy-refresh caching."""
    if _should_refresh('alarm'):
        add_timer(_refresh_alarm, 0.1, False)
    return _cached_data['alarm'].value

def _refresh_alarm(timer_id):
    """Background fetch for alarm data."""
    command = _get_config('alarm', 'command')
    if not command:
        return
    out = subprocess.getoutput(command)
    if out > "00:30":
        result = { "icon": " ", "color": "#06d6a0" , "text": out }
    elif out > "00:05":
        result = { "icon": " ", "color": "#ffd166" , "text": out, "inverse": True }
    elif len(out) > 0:
        result = { "icon": "󰺁 ", "color": "#ef476f" , "text": out, "inverse": True, "blink": True }
    else:
        result = None
    _cached_data['alarm'].value = result
    _cached_data['alarm'].timestamp = time.time()
    _redraw_tab_bar(None)

def get_time() -> dict:
    """Get current time cell with clock icon showing the hour."""
    now = datetime.datetime.now()
    time_str = now.strftime("%H:%M")

    # Map hour (12-hour format) to nerd font clock icon
    hour_icons = {
        1: "󱑋 ",   # nf-md-clock_time_one_outline
        2: "󱑌 ",   # nf-md-clock_time_two_outline
        3: "󱑍 ",   # nf-md-clock_time_three_outline
        4: "󱑎 ",   # nf-md-clock_time_four_outline
        5: "󱑏 ",   # nf-md-clock_time_five_outline
        6: "󱑐 ",   # nf-md-clock_time_six_outline
        7: "󱑑 ",   # nf-md-clock_time_seven_outline
        8: "󱑒 ",   # nf-md-clock_time_eight_outline
        9: "󱑓 ",   # nf-md-clock_time_nine_outline
        10: "󱑔 ",  # nf-md-clock_time_ten_outline
        11: "󱑕 ",  # nf-md-clock_time_eleven_outline
        12: "󱑖 ",  # nf-md-clock_time_twelve_outline
    }

    hour_12 = now.hour % 12
    if hour_12 == 0:
        hour_12 = 12

    icon = hour_icons.get(hour_12, "󰥒 ")
    return {"icon": icon, "color": "#669bbc", "text": time_str}


def get_date() -> dict:
    """Get date cell with weekday-appropriate icon."""
    today = datetime.date.today()
    if today.weekday() < 5:
        return {"icon": "󰃵 ", "color": "#2a9d8f", "text": today.strftime("%b %d")}
    else:
        return {"icon": "󰧓 ", "color": "#f2e8cf", "text": today.strftime("%b %d")}


def get_email(type: str, color: str = "#e76f51") -> dict | None:
    """Get email count for given account type with lazy-refresh caching."""
    cache_key = f'email_{type}'
    if _should_refresh(cache_key):
        add_timer(lambda t: _refresh_email(t, type, color), 0.1, False)
    return _cached_data[cache_key].value


def _refresh_email(timer_id, type: str, color: str) -> None:
    """Background fetch for email count."""
    section = f'mail.{type}'
    command = _get_config(section, 'command')
    if not command: return
    icon = _get_config(section, 'icon', '?')
    out = subprocess.getoutput(command)
    if out != '0':
        result = {"icon": icon + " ", "color": color, "text": out}
    else:
        result = None
    cache_key = f'email_{type}'
    _cached_data[cache_key].value = result
    _cached_data[cache_key].timestamp = time.time()
    _redraw_tab_bar(None)


# ============================================================================
# Utilities
# ============================================================================

def _redraw_tab_bar(timer_id) -> None:
    """Mark all tab bars as dirty, triggering a redraw."""
    for tm in get_boss().all_tab_managers:
        tm.mark_tab_bar_dirty()

