---Central registry of all pub/sub event name constants.
---@class events
---@field INPUT_ACTION table<string, string> State input action constants.
local events = {}

events.GAME_DEBUG_COLLIDERS = "game:debug_colliders"
events.GAME_DEBUG_TOGGLED = "game:debug_toggled"

events.REALM_WARP_TRIGGERED = "realm:warp_triggered"
events.REALM_FIRE_PROJECTILE = "realm:fire_projectile"

---Input action payloads sent to state-scoped events.
---@enum InputAction
events.INPUT_ACTION = {
    INTERACT = "interact",
    TOGGLE_MENU = "toggle_menu",
    TOGGLE_PAUSE = "toggle_pause",
    FIRE_PROJECTILE = "fire_projectile",
    MELEE_ATTACK = "melee_attack",
}

-- Prefix for event names scoped to a state: append the state's name.
events.STATE_INPUT_PREFIX = "state:input:"

return events
