---@class Vessel
---@field x number
---@field y number
---@field width number
---@field height number
---@field collider collider
local Vessel = {}
Vessel.__index = Vessel

---Set the position of the vessel.
---@param x number
---@param y number
---@return nil
function Vessel:setPosition(x, y)
    self.collider:setPosition(x, y)
end

---Get the position of the vessel.
---@return number x
---@return number y
function Vessel:getPosition()
    return self.collider:getPosition()
end

---Set the linear velocity of the vessel.
---@param vx number
---@param vy number
---@return nil
function Vessel:setLinearVelocity(vx, vy)
    self.collider:setLinearVelocity(vx, vy)
end

---Get the linear velocity of the vessel.
---@return number vx
---@return number vy
function Vessel:getLinearVelocity()
    return self.collider:getLinearVelocity()
end

---Destroy the vessel.
---@return nil
function Vessel:destroy()
    if self.collider then
        self.collider:destroy()
    end
end

---Create a new Vessel with a physics collider.
---@param opts {physics: physics, x?: number, y?: number, width?: number, height?: number, shape?: "rectangle"|"octagon", bodyType?: love.BodyType, group?: number, tags?: string[]}
---@return Vessel
function Vessel.new(opts)
    local self = setmetatable({}, Vessel)
    assert(opts.physics, "Vessel requires a physics instance")
    self.x = opts.x or 0
    self.y = opts.y or 0
    self.width = opts.width or 16
    self.height = opts.height or 16

    local collisionOpts = {
        width = self.width - 2,
        height = self.height,
        shape = opts.shape or "octagon",
        bodyType = opts.bodyType or "dynamic",
        bevel = 3,
        group = opts.group,
    }
    self.collider = opts.physics:collider(self.x, self.y, collisionOpts)

    if opts.tags then
        self.collider:addTags(unpack(opts.tags))
    end

    return self
end

return Vessel
