--- Global constants for virtual resolution, window size, input keys, and timing rates.
--- Loaded once via src/deps.lua and accessible from all modules as globals.

-- maintain 3:2 aspect ratio to match virtual window
WINDOW_WIDTH = 1080
WINDOW_HEIGHT = 720

-- keyboard constants for configurability
KEY_UP = "w"
KEY_DOWN = "s"
KEY_LEFT = "a"
KEY_RIGHT = "d"

KEY_DEBUG_COLLIDERS = "."
KEY_DEBUG_MENU = ","
KEY_INTERACT = "e"
KEY_MENU = "tab"
KEY_PAUSE = "p"
KEY_SHURIKEN = "q"

-- rate in seconds of the start screen fade duration
FADE_RATE = 0.6

-- should be set for player/souls so their colliders do not collide
COLLISION_GROUP_PASS_THROUGH = -1
