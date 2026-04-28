---No-op base class for all game states.
---Subclasses override the lifecycle methods they need; unoverridden methods are harmless no-ops.
---@class BaseState
local BaseState = {}
BaseState.__index = BaseState

---Called when this state becomes active. Override to perform setup.
---@param opts? table Optional options
---@return nil
function BaseState:enterState(opts) end

---Called when this state is deactivated. Override to perform teardown.
---@return nil
function BaseState:exitState() end

---Called every frame while this state is active.
---@param dt number Delta time in seconds
---@return nil
function BaseState:update(dt) end

---Called every frame after the physics world steps.
---@param dt number Delta time in seconds
---@return nil
function BaseState:postPhysicsUpdate(dt) end

---Called every frame to render this state.
---@return nil
function BaseState:draw() end

---Create a new BaseState
---@generic T : BaseState
---@param subclass? T Metatable to use (defaults to BaseState)
---@return T
function BaseState.new(subclass)
	return setmetatable({}, subclass or BaseState)
end

return BaseState
