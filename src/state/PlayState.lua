local BaseState = require("src.state.BaseState")

local PlayState = {}
PlayState.__index = PlayState
setmetatable(PlayState, { __index = BaseState })

local pauseGame = false

function PlayState:enterState(args)
	if args and args.previousState and args.previousState == "start" then
		self.fadeAlpha = 1
		self.isFading = true

		Timer.tween(FADE_RATE, { [self] = { fadeAlpha = 0 } }):finish(function()
			self.isFading = false
		end)
	end
end

function PlayState:exitState()
	-- TODO: should be done in realm class after loading new map or need more global destroyAll here
	self.realm:destroyMap()
end

function PlayState:update(dt)
	self.realm:CameraLookAtPlayer()

	-- TODO: player currently looks walking on start, because animation not updated yet due to this early return
	-- Should be fixable when implmenting player idle state
	-- Adding gotoFrame is a workaround
	if self.isFading then
		self.realm.player.animations.current:gotoFrame(1)
		return
	end

	if love.keyboard.wasPressed(KEY_PAUSE) then
		pauseGame = not pauseGame
	end

	if not pauseGame then
		self.realm:update(dt)
	end
end

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

function PlayState.new()
	local self = BaseState.new(PlayState)

	self.realm = Realm.new()
	self.realm:loadMap("map-hometown", self.realm.player.x, self.realm.player.y)

	self.fadeAlpha = 1
	self.isFading = false

	return self
end

return PlayState
