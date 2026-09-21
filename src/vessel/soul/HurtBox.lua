---@class DamageHit
---@field source Soul|Husk Entity that dealt the damage.
---@field collider collider Collider found by the hurtbox query.
---@field damage number Damage amount.
---@field knockbackSpeed number Knockback speed applied by the damage source.
---@field x number Source X position.
---@field y number Source Y position.
---@field damageType string Source damage type.

---@class HurtBox
---@field owner Soul Owning soul.
---@field radius number Hurt radius in pixels.
---@field offsetX number Horizontal offset from owner.
---@field offsetY number Vertical offset from owner.
---@field damageTags string[] Accepted damage tags.
local HurtBox = {}
HurtBox.__index = HurtBox

---Return whether this hurtbox accepts the source's damage type.
---@param source { damageSource?: DamageSource } Entity or transient attack descriptor.
---@return boolean
function HurtBox:acceptsDamageFrom(source)
    local damageSource = source.damageSource
    if not damageSource then
        return false
    end

    for _, acceptedType in ipairs(self.damageTags) do
        if damageSource.type == acceptedType then
            return true
        end
    end

    return false
end

---Build a damage hit payload from an accepted damage source.
---@param source Soul|Husk
---@param collider collider
---@return DamageHit
local function makeDamageHit(source, collider)
    local px, py = source:getPosition()

    return {
        source = source,
        collider = collider,
        damage = source.damageSource.amount,
        knockbackSpeed = source.damageSource.knockbackSpeed,
        x = px,
        y = py,
        damageType = source.damageSource.type,
    }
end

---Query damage hits overlapping this hurtbox.
---@return DamageHit[]
function HurtBox:query()
    local world = self.owner.collider.body:getWorld()
    local px, py = self.owner:getPosition()
    local hits = {}

    local colliders = Collision.queryCircleArea(world, px + self.offsetX, py + self.offsetY, self.radius, function(c)
        local source = c.owner
        if source == self.owner or not source then
            return false
        end

        return self:acceptsDamageFrom(source)
    end, 1)

    for _, collider in ipairs(colliders) do
        table.insert(hits, makeDamageHit(collider.owner, collider))
    end

    return hits
end

---Create a new hurtbox for a Soul.
---@param owner Soul
---@param opts HurtBoxConfig
---@return HurtBox
function HurtBox.new(owner, opts)
    local self = setmetatable({}, HurtBox)
    assert(owner, "HurtBox must have an owner.")
    self.owner = owner
    self.radius = opts.radius or 5
    self.offsetX = opts.offsetX or 0
    self.offsetY = opts.offsetY or 0
    self.damageTags = {} -- TODO: if no tags, make hurtbox succesptible to all damage

    for _, tag in ipairs(opts.damageTags or {}) do
        Damage.assertValidType(tag)
        table.insert(self.damageTags, tag)
    end

    return self
end

return HurtBox
