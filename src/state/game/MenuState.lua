local BaseState = require("src.state.BaseState")

---Menu overlay state.
---@class MenuState : BaseState
---@field stateName string
---@field unhearken Unhearken?
local MenuState = {}
MenuState.__index = MenuState
setmetatable(MenuState, { __index = BaseState })

---@type string
MenuState.STATE_NAME = "menu"

---Called when this state becomes active.
---@return nil
function MenuState:enterState()
	---@param action StateInputAction
	self.unhearken = Herald.hearken(Events.STATE_INPUT_PREFIX .. self.stateName, function(action)
		if action == "toggle_menu" then
			GStateStack:pop()
		end
	end)
end

---Called when this state is deactivated.
---@return nil
function MenuState:exitState()
	if self.unhearken then
		self.unhearken()
		self.unhearken = nil
	end
end

---@param dt number Delta time in seconds
---@return nil
function MenuState:update(dt) end

---Render the menu panel.
---@return nil
function MenuState:draw()
	-- TODO: make menu normal size again
	Util.safeDraw(function()
		local screenWidth = View.getWidth()
		local screenHeight = View.getHeight()
		local panelWidth = math.min(screenWidth - 32, 420)
		local panelHeight = math.min(screenHeight - 32, 280)
		local panelX = (screenWidth - panelWidth) / 2
		local panelY = (screenHeight - panelHeight) / 2

		GTheme.panels.wood:draw(panelX, panelY, panelWidth, panelHeight)
		GTheme.panels.woodInterior:draw(panelX + 7, panelY + 7, panelWidth - 14, panelHeight - 14)

		love.graphics.setColor(GTheme.colors.text)
		love.graphics.setFont(GTheme.fonts.title)
		love.graphics.print("MENU TEST", panelX + 10, panelY + 8, 0, 0.5, 0.5)

		love.graphics.setFont(GTheme.fonts.body)
		love.graphics.print("menu test", panelX + 10, panelY + 18, 0, 0.5, 0.5)
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
