local BaseState = require("src.state.BaseState")

---Title screen state.
---@class StartState : BaseState
---@field stateName string
local StartState = {}
StartState.__index = StartState
setmetatable(StartState, { __index = BaseState })

---@type string
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
	-- TODO: draw dark moon texture as background
	love.graphics.clear(love.math.colorFromBytes(42, 42, 46))

	-- TODO: can we simplify this function?
	-- TODO: might need to scale font dynnamically to match window size
	Util.safeDraw(function()
		local screenWidth = View.getWidth()
		local screenHeight = View.getHeight()
		local titleText = "Dalbit\nNinja"
		local titleFont = GFonts["startTitle"]
		local subtitleFont = GFonts["startPrompt"]
		titleFont:setLineHeight(0.7)

		local titleHeight = titleFont:getHeight() * titleFont:getLineHeight() * 2
		local gap = 128
		local verticalOffset = screenHeight * 0.16
		local titleY = (screenHeight - titleHeight) / 2 - verticalOffset
		local subtitleY = titleY + titleHeight + gap

		love.graphics.setFont(titleFont)

		-- farthest layer
		love.graphics.setColor(love.math.colorFromBytes(162, 135, 138))
		love.graphics.printf(titleText, 8, titleY + 10, screenWidth, "center")

		-- middle layer
		love.graphics.setColor(love.math.colorFromBytes(176, 158, 160))
		love.graphics.printf(titleText, 4, titleY + 5, screenWidth, "center")

		-- closest layer
		love.graphics.setColor(love.math.colorFromBytes(218, 206, 211))
		love.graphics.printf(titleText, 0, titleY, screenWidth, "center")

		love.graphics.setColor(love.math.colorFromBytes(218, 206, 211))
		love.graphics.setFont(subtitleFont)
		love.graphics.printf("Press Enter", 0, subtitleY, screenWidth, "center")
	end)

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
