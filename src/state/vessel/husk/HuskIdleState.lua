local BaseState = require("src.state.BaseState")

---@class HuskIdleState : BaseState
---@field husk Husk
local HuskIdleState = {}
HuskIdleState.__index = HuskIdleState
setmetatable(HuskIdleState, { __index = BaseState })

---Called when this state becomes active.
---@param opts? table Optional arguments
function HuskIdleState:enterState(opts)
	if self.husk.animations and self.husk.animations.current then
		if self.husk.animOpts and self.husk.animOpts.paused ~= false then
			self.husk.animations.current:pauseAtStart()
		end
	end
end

---Create a new HuskIdleState
---@generic T : HuskIdleState
---@param husk Husk
---@return T
function HuskIdleState.new(husk)
	local self = BaseState.new(HuskIdleState)
	self.husk = husk
	return self
end

return HuskIdleState
