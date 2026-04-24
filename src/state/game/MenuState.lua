local BaseState = require("src.state.BaseState")

---Menu overlay state.
---@class MenuState : BaseState
---@field stateName string
---@field unhearken Unhearken?
local MenuState = {}
MenuState.__index = MenuState
setmetatable(MenuState, { __index = BaseState })

MenuState.STATE_NAME = "menu"

---Called when this state becomes active.
function MenuState:enterState()
	---@param action StateInputAction
	self.unhearken = Herald.hearken(Events.STATE_INPUT_PREFIX .. self.STATE_NAME, function(action)
		if action == "toggle_menu" then
			GStateStack:pop()
		end
	end)
end

---Called when this state is deactivated.
function MenuState:exitState()
	if self.unhearken then
		self.unhearken()
		self.unhearken = nil
	end
end

---@param dt number Delta time in seconds
function MenuState:update(dt) end

---Render the menu panel.
function MenuState:draw()
	Util.safeDraw(function()
		GTheme.panels.wood:draw(10, 10, VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT - 20)
		GTheme.panels.woodInterior:draw(17, 17, VIRTUAL_WIDTH - 34, VIRTUAL_HEIGHT - 34)

		love.graphics.setColor(GTheme.colors.text)
		love.graphics.setFont(GTheme.fonts.title)
		love.graphics.print("MENU TEST", 20, 18, 0, 0.5, 0.5)

		love.graphics.setFont(GTheme.fonts.body)
		love.graphics.print("menu test", 20, 28, 0, 0.5, 0.5)
	end)
end

---Create a new MenuState
---@return MenuState
function MenuState.new()
	local self = BaseState.new(MenuState)
	self.stateName = MenuState.STATE_NAME
	return self
end

return MenuState
