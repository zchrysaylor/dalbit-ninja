---Central registry of all pub/sub event name constants.
---@class events
local events = {}

events.GAME_DEBUG_COLLIDERS = "game:debug_colliders"
events.GAME_DEBUG_TOGGLED = "game:debug_toggled"

events.REALM_WARP_TRIGGERED = "realm:warp_triggered"

---@alias StateInputAction
---| "interact"
---| "toggle_menu"
---| "toggle_pause"
events.STATE_INPUT_PREFIX = "state:input:"

return events
