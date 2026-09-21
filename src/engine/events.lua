---Central registry of all pub/sub event name constants.
---@class events
local events = {}

events.GAME_DEBUG_COLLIDERS = "game:debug_colliders"
events.GAME_DEBUG_TOGGLED = "game:debug_toggled"

events.REALM_WARP_TRIGGERED = "realm:warp_triggered"
events.REALM_FIRE_PROJECTILE = "realm:fire_projectile"

-- TODO: better name and/or way to define these? With constants so strings not used in code?
-- AFAIK alias is also not doing any type checking; it's only for LSP
---@alias StateInputAction
---| "interact"
---| "toggle_menu"
---| "toggle_pause"
---| "fire_projectile"
---| "melee_attack"

-- TODO: make states constants?
events.STATE_INPUT_PREFIX = "state:input:"

return events
