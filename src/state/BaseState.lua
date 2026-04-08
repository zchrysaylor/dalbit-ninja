local BaseState = {}
BaseState.__index = BaseState

function BaseState:enterState() end
function BaseState:exitState() end
function BaseState:update(dt) end
function BaseState:draw() end

function BaseState.new(subclass)
	return setmetatable({}, subclass or BaseState)
end

return BaseState
