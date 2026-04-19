---Central registry of all pub/sub event name constants.
---@class events
local events = {}

events.GAME_DEBUG_TOGGLED = "game:debug_toggled"
events.GAME_MENU_TOGGLED = "game:menu_toggled"
events.GAME_PAUSE_TOGGLED = "game:pause_toggled"

events.REALM_WARP_TRIGGERED = "realm:warp_triggered"

events.PLAYER_INTERACT = "player:interact"

return events
