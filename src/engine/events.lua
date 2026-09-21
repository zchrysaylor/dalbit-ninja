---Central registry of all pub/sub event name constants.
---@class events
local events = {}

events.GAME_DEBUG_COLLIDERS = "game:debug_colliders"
events.GAME_DEBUG_TOGGLED = "game:debug_toggled"

events.REALM_WARP_TRIGGERED = "realm:warp_triggered"
events.REALM_FIRE_PROJECTILE = "realm:fire_projectile"

-- TODO: make states constants w/composable elements like:
-- STATE_INPUT_PREFIX = "state:input:"
-- ATTACK_PREFIX = "attack:"
-- MELEE_ATTACK_EVENT = STATE_INPUT_PREFIX + ATTACK_PREFIX + "melee"

---@alias StateInputAction
---| "interact"
---| "toggle_menu"
---| "toggle_pause"
---| "fire_projectile"
---| "melee_attack"
events.STATE_INPUT_PREFIX = "state:input:"

return events
