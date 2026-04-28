local BaseState = require("src.state.BaseState")

---Walking state for soul entities.
---@class SoulWalkState : BaseState
---@field stateName string
---@field soul Soul
local SoulWalkState = {}
SoulWalkState.__index = SoulWalkState
setmetatable(SoulWalkState, { __index = BaseState })

SoulWalkState.STATE_NAME = "walk"

---Called when this state becomes active.
---@param opts? table Optional options
---@return nil
function SoulWalkState:enterState(opts)
	-- TODO: fix bug where player always idles down due to inheriting this method
	-- TODO: remove this class entirely
	self.soul:setIsAnimating(true)
	self.soul:refreshAnimation()
end

---Called when this state is deactivated.
---@return nil
function SoulWalkState:exitState()
	self.soul.vessel:setLinearVelocity(0, 0)
end

---Advance movement while this state is active.
---@param dt number Delta time in seconds
---@return nil
function SoulWalkState:update(dt) end

---Create a new SoulWalkState
---@generic T : SoulWalkState
---@param soul Soul
---@param subclass? T Metatable to use (defaults to SoulWalkState)
---@return T
function SoulWalkState.new(soul, subclass)
	local self = BaseState.new(subclass or SoulWalkState)
	self.stateName = (subclass or SoulWalkState).STATE_NAME
	self.soul = soul
	return self
end

return SoulWalkState
