local BaseState = require("src.state.BaseState")

---Title screen state.
---@class StartState : BaseState
---@field stateName string
local StartState = {}
StartState.__index = StartState
setmetatable(StartState, { __index = BaseState })

StartState.STATE_NAME = "start"

---@param dt number Delta time in seconds
---@return nil
function StartState:update(dt)
	if Input:wasPressed("enter") or Input:wasPressed("return") then
		if not Transition.isActive then
			Transition.fade(FADE_RATE, function()
				GStateStack:pop()
				GStateStack:push(PlayState.new())
			end)
		end
	end
end

---Render the title screen.
---@return nil
function StartState:draw()
	-- since we are using Push, we need to manually clear the canvas for the background color to take effect
	love.graphics.clear(love.math.colorFromBytes(42, 42, 46))

	local font = GFonts["ninjaLarge"]
	love.graphics.setFont(font)
	font:setLineHeight(0.7)
	local y = VIRTUAL_HEIGHT / 2 - 56

	-- farthest layer
	love.graphics.setColor(love.math.colorFromBytes(162, 135, 138))
	love.graphics.printf("Dalbit\nNinja", 2, y + 4, VIRTUAL_WIDTH, "center")

	-- middle layer
	love.graphics.setColor(love.math.colorFromBytes(176, 158, 160))
	love.graphics.printf("Dalbit\nNinja", 1, y + 2, VIRTUAL_WIDTH, "center")

	-- closest layer
	love.graphics.setColor(love.math.colorFromBytes(218, 206, 211))
	love.graphics.printf("Dalbit\nNinja", 0, y, VIRTUAL_WIDTH, "center")

	love.graphics.setColor(love.math.colorFromBytes(218, 206, 211))
	love.graphics.setFont(GFonts["ninjaSmall"])
	love.graphics.printf("Press Enter", -2, VIRTUAL_HEIGHT / 2 + 32, VIRTUAL_WIDTH, "center")

	Transition.draw()
end

---Create a new StartState
---@return StartState
function StartState.new()
	local self = BaseState.new(StartState)
	self.stateName = StartState.STATE_NAME
	return self
end

return StartState
