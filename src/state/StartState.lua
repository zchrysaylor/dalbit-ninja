local BaseState = require("src.state.BaseState")

---Title screen state.
---@class StartState : BaseState
---@field alpha number Current opacity of the title content (1 = fully visible, 0 = invisible)
---@field isFading boolean True while the fade-out tween is running
local StartState = {}
StartState.__index = StartState
setmetatable(StartState, { __index = BaseState })

---Handle input: Escape quits, Enter/Return begins a fade-out tween into PlayState.
---@param dt number Delta time in seconds
function StartState:update(dt)
	-- Only start fade if not already fading
	if not self.isFading and (Input:wasPressed("enter") or Input:wasPressed("return")) then
		self.isFading = true
		Flux.to(self, FADE_RATE, { alpha = 0 }):ease("quadin"):oncomplete(function()
			GStateMachine:changeState("play", { previousState = "start" })
		end)
	end
end

---Render the title screen.
---Uses self.alpha for the fade-in/out effect driven by the Flux tween.
function StartState:draw()
	-- since we are using Push, we need to manually clear the canvas for the background color to take effect
	love.graphics.clear(love.math.colorFromBytes(42, 42, 46))

	-- Full screen fade overlay (covers background too)
	love.graphics.setColor(0, 0, 0, 1 - self.alpha)
	love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

	love.graphics.setFont(GFonts["sproutlandsLarge"])

	-- farthest layer; red
	love.graphics.setColor(love.math.colorFromBytes(207, 132, 149, self.alpha * 255))
	love.graphics.printf("Lua Boy Advance", 0, VIRTUAL_HEIGHT / 2 - 42, VIRTUAL_WIDTH, "center")

	-- middle layer; green
	love.graphics.setColor(love.math.colorFromBytes(146, 188, 116, self.alpha * 255))
	love.graphics.printf("Lua Boy Advance", 2, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, "center")

	-- closest layer; blue
	love.graphics.setColor(love.math.colorFromBytes(120, 162, 176, self.alpha * 255))
	love.graphics.printf("Lua Boy Advance", 4, VIRTUAL_HEIGHT / 2 - 38, VIRTUAL_WIDTH, "center")

	love.graphics.setColor(1, 1, 1, self.alpha)
	love.graphics.setFont(GFonts["sproutlandsSmall"])
	love.graphics.printf("Press Enter", 0, VIRTUAL_HEIGHT / 2 + 30, VIRTUAL_WIDTH, "center")
end

---Create a new StartState
---@return StartState
function StartState.new()
	local self = BaseState.new(StartState)
	self.alpha = 1
	self.isFading = false
	return self
end

return StartState
