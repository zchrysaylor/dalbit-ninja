local BaseState = require("src.state.BaseState")

---Title screen state.
---@class StartState : BaseState
local StartState = {}
StartState.__index = StartState
setmetatable(StartState, { __index = BaseState })

---@param dt number Delta time in seconds
function StartState:update(dt)
	if Input:wasPressed("enter") or Input:wasPressed("return") then
		if not Transition.isActive then
			Transition.fade(FADE_RATE, function()
				-- TODO: actually make use of passed previousState or remove, currently does nothing
				GStateMachine:changeState("play", { previousState = "start" })
			end)
		end
	end
end

---Render the title screen.
function StartState:draw()
	-- since we are using Push, we need to manually clear the canvas for the background color to take effect
	love.graphics.clear(love.math.colorFromBytes(42, 42, 46))

	love.graphics.setFont(GFonts["sproutlandsLarge"])

	-- farthest layer; red
	love.graphics.setColor(love.math.colorFromBytes(207, 132, 149))
	love.graphics.printf("Lua Boy Advance", 0, VIRTUAL_HEIGHT / 2 - 42, VIRTUAL_WIDTH, "center")

	-- middle layer; green
	love.graphics.setColor(love.math.colorFromBytes(146, 188, 116))
	love.graphics.printf("Lua Boy Advance", 2, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, "center")

	-- closest layer; blue
	love.graphics.setColor(love.math.colorFromBytes(120, 162, 176))
	love.graphics.printf("Lua Boy Advance", 4, VIRTUAL_HEIGHT / 2 - 38, VIRTUAL_WIDTH, "center")

	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(GFonts["sproutlandsSmall"])
	love.graphics.printf("Press Enter", 0, VIRTUAL_HEIGHT / 2 + 30, VIRTUAL_WIDTH, "center")

	Transition.draw()
end

---Create a new StartState
---@return StartState
function StartState.new()
	return BaseState.new(StartState)
end

return StartState
