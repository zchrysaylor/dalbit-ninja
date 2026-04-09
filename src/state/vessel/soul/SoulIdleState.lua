local BaseState = require("src.state.BaseState")

---@class SoulIdleState : BaseState
---@field entity Soul
local SoulIdleState = {}
SoulIdleState.__index = SoulIdleState
setmetatable(SoulIdleState, { __index = BaseState })

function SoulIdleState:enterState(args)
	self.entity.animations.current:pauseAtStart()
end

function SoulIdleState:update(dt) end

---@param entity Soul
---@return SoulIdleState
function SoulIdleState.new(entity)
	local self = BaseState.new(SoulIdleState)
	-- TODO: refactor to self.soul
	self.entity = entity
	return self
end

return SoulIdleState
