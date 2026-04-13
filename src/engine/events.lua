---@module events
---Central registry of all pub/sub event name constants.
---Use these with Signal.connect / Signal.emit to avoid string typos.
local events = {}

events.GAME_PAUSE_TOGGLED = "game:pause_toggled"

return events
