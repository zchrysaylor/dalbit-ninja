local BaseState = require("src.state.BaseState")

---Main gameplay state.
---@class PlayState : BaseState
---@field stateName string
---@field realm Realm The active world/level controller
---@field isPaused boolean True while the game is paused
---@field heraldGroup HeraldMuster?
local PlayState = {}
PlayState.__index = PlayState
setmetatable(PlayState, { __index = BaseState })

---@type string
PlayState.STATE_NAME = "play"

---Called when this state becomes active.
---@param opts? table Optional options.
---@return nil
function PlayState:enterState(opts)
    self.heraldGroup = Herald.muster()

    self.heraldGroup:hearken(Events.REALM_WARP_TRIGGERED, function(warp)
        Transition.fade(FADE_RATE, function()
            self.realm:loadMap(warp.mapName, warp.destX, warp.destY)
        end)
    end)

	---@param action StateInputAction
	self.heraldGroup:hearken(Events.STATE_INPUT_PREFIX .. self.stateName, function(action)
		if action == "interact" then
			self.realm.player:interact()
		elseif action == "fire_projectile" then
			self.realm.player:fireProjectile()
		elseif action == "toggle_menu" then
			GStateStack:push(MenuState.new())
		elseif action == "toggle_pause" then
			self.isPaused = not self.isPaused
		end
	end)
end

---Called when this state is deactivated.
---@return nil
function PlayState:exitState()
    if self.heraldGroup then
        self.heraldGroup:unhearkenAll()
        self.heraldGroup = nil
    end

    self.realm:destroy()
end

---@param dt number Delta time in seconds
---@return nil
function PlayState:update(dt)
    if not Transition.isActive and not self.isPaused then
        self.realm:update(dt)
    end
end

---Render the active realm and pause/transition overlays.
---@return nil
function PlayState:draw()
    self.realm:draw()
    Transition.draw() -- must be drawn after realm's draw to take effect

    if self.isPaused then
        -- TODO: Make normal size again
        Util.safeDraw(function()
            love.graphics.setColor(love.math.colorFromBytes(218, 206, 211))
            love.graphics.setFont(GFonts["ninjaMedium"])
            love.graphics.printf(
                "Game Paused. Press 'p' to resume.",
                0,
                View.getHeight() / 2,
                View.getWidth(),
                "center"
            )
        end)
    end
end

---Create a new PlayState
---@return PlayState
function PlayState.new()
    local self = BaseState.new(PlayState)
    self.stateName = PlayState.STATE_NAME

    self.realm = Realm.new()
    self.realm:loadMap("map-start", self.realm.player.x, self.realm.player.y)

    self.isPaused = false

    return self
end

return PlayState
