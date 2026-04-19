local BaseState = require("src.state.BaseState")

local MenuState = {}
MenuState.__index = MenuState
setmetatable(MenuState, { __index = BaseState })

MenuState.STATE_NAME = "menu"

function MenuState:update(dt) end

function MenuState:draw()
	Util.safeDraw(function()
		love.graphics.setColor(0, 0, 0, 0.7)
		love.graphics.rectangle("fill", 10, 10, VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT - 20)

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(GFonts["ninjaSmall"])
		love.graphics.print("menu TESTING 123 hello", VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 0, 0.5, 0.5)
	end)
end

function MenuState.new()
	local self = BaseState.new(MenuState)
	self.stateName = MenuState.STATE_NAME
	return self
end

return MenuState
