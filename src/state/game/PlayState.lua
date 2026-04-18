local BaseState = require("src.state.BaseState")

---Main gameplay state.
---@class PlayState : BaseState
---@field realm Realm The active world/level controller
---@field isPaused boolean True while the game is paused
---@field signalGroup SignalGroup?
local PlayState = {}
PlayState.__index = PlayState
setmetatable(PlayState, { __index = BaseState })

---Called when this state becomes active.
---@param opts? table Optional options.
function PlayState:enterState(opts)
	self.signalGroup = Signal.group()
	self.signalGroup:connect(Events.GAME_PAUSE_TOGGLED, function()
		self.isPaused = not self.isPaused
	end)
	self.signalGroup:connect(Events.REALM_WARP_TRIGGERED, function(warp)
		Transition.fade(FADE_RATE, function()
			self.realm:loadMap(warp.mapName, warp.destX, warp.destY)
		end)
	end)
	self.signalGroup:connect(Events.PLAYER_INTERACT, function()
		self.realm.player:interact()
	end)
end

---Called when this state is deactivated.
function PlayState:exitState()
	if self.signalGroup then
		self.signalGroup:disconnectAll()
		self.signalGroup = nil
	end

	self.realm:destroyAll()
	self.realm.player:destroy()
end

---@param dt number Delta time in seconds
function PlayState:update(dt)
	if Transition.isActive then
		return
	end

	if not self.isPaused then
		self.realm:update(dt)
	end
end

function PlayState:draw()
	self.realm:draw()
	Transition.draw() -- must be drawn after realm's draw to take effect

	if self.isPaused then
		Util.safeDraw(function()
			love.graphics.setColor(love.math.colorFromBytes(64, 39, 81))
			love.graphics.setFont(GFonts["antiquity"])
			love.graphics.printf(
				"Game Paused. Press 'p' to resume.",
				0,
				(Push:getHeight() / 2) - 0,
				Push:getWidth(),
				"center"
			)
		end)
	end
end

---Create a new PlayState
---@return PlayState
function PlayState.new()
	local self = BaseState.new(PlayState)

	self.realm = Realm.new()
	self.realm:loadMap("map-start", self.realm.player.x, self.realm.player.y)

	self.isPaused = false

	return self
end

return PlayState
