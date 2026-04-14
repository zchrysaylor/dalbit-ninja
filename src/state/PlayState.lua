local BaseState = require("src.state.BaseState")

---Main gameplay state. Owns a Realm and handles pause, fade-in from StartState, and rendering.
---@class PlayState : BaseState
---@field realm Realm The active world/level controller
---@field fadeAlpha number Black overlay opacity during transition (0 = transparent, 1 = opaque)
---@field isFading boolean True while the entry fade-in tween is running
---@field isPaused boolean True while the game is paused
---@field unsubPauseToggled Unsubscribe Unsubscribe handle for the pause toggled Signal subscription
local PlayState = {}
PlayState.__index = PlayState
setmetatable(PlayState, { __index = BaseState })

---Called when this state becomes active.
---If transitioning from "start", starts a black-overlay fade-in tween.
---Subscribes to Events.GAME_PAUSE_TOGGLED to toggle self.isPaused.
---@param args? table Optional arguments. `args.previousState` may be `"start"` to trigger a fade-in.
function PlayState:enterState(args)
	if args and args.previousState and args.previousState == "start" then
		self.fadeAlpha = 1
		self.isFading = true
		Flux.to(self, FADE_RATE, { fadeAlpha = 0 }):oncomplete(function()
			self.isFading = false
		end)
	end

	self.unsubPauseToggled = Signal.connect(Events.GAME_PAUSE_TOGGLED, function()
		self.isPaused = not self.isPaused
	end)
end

---Called when this state is deactivated. Unsubscribes from Signal events and destroys all realm entities.
function PlayState:exitState()
	if self.unsubPauseToggled then
		self.unsubPauseToggled()
	end
	self.realm:destroyAll()
end

---Update camera, handle pause toggling, and delegate to realm update (skipped while fading or paused).
---@param dt number Delta time in seconds
function PlayState:update(dt)
	if self.isFading then
		return
	end

	if not self.isPaused then
		self.realm:update(dt)
	end
end

---Render the realm, the fade overlay (if fading), and the pause text (if paused).
function PlayState:draw()
	self.realm:draw()

	if self.isFading then
		Util.safeDraw(function()
			love.graphics.setColor(0, 0, 0, self.fadeAlpha)
			love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
		end)
	end

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
	self.realm:loadMap("map-hometown", self.realm.player.x, self.realm.player.y)

	self.fadeAlpha = 1
	self.isFading = false
	self.isPaused = false

	return self
end

return PlayState
