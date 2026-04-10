local BaseState = require("src.state.BaseState")

---Main gameplay state. Owns a Realm and handles pause, fade-in from StartState, and rendering.
---@class PlayState : BaseState
---@field realm Realm The active world/level controller
---@field fadeAlpha number Black overlay opacity during transition (0 = transparent, 1 = opaque)
---@field isFading boolean True while the entry fade-in tween is running
local PlayState = {}
PlayState.__index = PlayState
setmetatable(PlayState, { __index = BaseState })

-- Module-level pause flag shared across all PlayState instances
local pauseGame = false

---Called when this state becomes active.
---If transitioning from "start", starts a black-overlay fade-in tween.
---@param args? table Optional arguments
function PlayState:enterState(args)
	if args and args.previousState and args.previousState == "start" then
		self.fadeAlpha = 1
		self.isFading = true

		Timer.tween(FADE_RATE, { [self] = { fadeAlpha = 0 } }):finish(function()
			self.isFading = false
		end)
	end
end

---Destroy all current realm entities when leaving this state.
function PlayState:exitState()
	-- TODO: should be done in realm class after loading new map or need more global destroyAll here
	self.realm:destroyAll()
end

---Update camera, handle pause toggling, and delegate to realm update (skipped while fading or paused).
---@param dt number Delta time in seconds
function PlayState:update(dt)
	self.realm:CameraLookAtPlayer()

	if self.isFading then
		return
	end

	if love.keyboard.wasPressed(KEY_PAUSE) then
		pauseGame = not pauseGame
	end

	if not pauseGame then
		self.realm:update(dt)
	end
end

---Render the realm, the fade overlay (if fading), and the pause text (if paused).
function PlayState:draw()
	self.realm:draw()

	if self.isFading then
		love.graphics.setColor(0, 0, 0, self.fadeAlpha)
		love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
	end

	if pauseGame then
		local r, g, b, a = love.graphics.getColor()
		love.graphics.setColor(love.math.colorFromBytes(64, 39, 81))
		love.graphics.setFont(GFonts["antiquity"])
		love.graphics.printf(
			"Game Paused. Press 'p' to resume.",
			0,
			(Push:getHeight() / 2) - 0,
			Push:getWidth(),
			"center"
		)
		love.graphics.setColor(r, g, b, a)
	end
end

---Create a new PlayState
---@return PlayState
function PlayState.new()
	local self = BaseState.new(PlayState)

	self.realm = Realm.new()
	self.realm:loadMap("map-hometown", self.realm.player.x, self.realm.player.y)

	self.fadeAlpha = 1
	self.isFading = false

	return self
end

return PlayState
