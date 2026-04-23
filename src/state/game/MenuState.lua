local BaseState = require("src.state.BaseState")

local MenuState = {}
MenuState.__index = MenuState
setmetatable(MenuState, { __index = BaseState })

-- TODO: add state name to every state
MenuState.STATE_NAME = "menu"

---@param dt number Delta time in seconds
function MenuState:update(dt) end

function MenuState:draw()
	Util.safeDraw(function()
		GInterface["panel-wood"]:draw(10, 10, VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT - 20)
		GInterface["panel-wood-interior"]:draw(17, 17, VIRTUAL_WIDTH - 34, VIRTUAL_HEIGHT - 34)

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(GFonts["ninjaMedium"])
		love.graphics.print("MENU TEST", 20, 18, 0, 0.5, 0.5)

		love.graphics.setFont(GFonts["ninjaSmall"])
		love.graphics.print("menu test", 20, 28, 0, 0.5, 0.5)
	end)
end

function MenuState.new()
	local self = BaseState.new(MenuState)
	self.stateName = MenuState.STATE_NAME
	return self
end

return MenuState
