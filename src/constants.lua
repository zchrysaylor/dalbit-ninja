--- Global constants for virtual resolution, window size, input keys, and timing rates.
--- Loaded once via src/deps.lua and accessible from all modules as globals.

-- original gameboy size: 240x160
-- consider 160×106 for a bit more zoom
VIRTUAL_WIDTH = 192
VIRTUAL_HEIGHT = 128

-- maintain 3:2 aspect ratio to match virtual window
WINDOW_WIDTH = 1080
WINDOW_HEIGHT = 720

-- keyboard constants for configurability
KEY_UP = "w"
KEY_DOWN = "s"
KEY_LEFT = "a"
KEY_RIGHT = "d"
KEY_PAUSE = "p"
KEY_DEBUG = "."

-- rate in seconds of the start screen fade duration
FADE_RATE = 0.6
