---@class DamageHit
---@field source Soul|Husk Entity that dealt the damage.
---@field collider collider Collider found by the hurtbox query.
---@field damage number Damage amount.
---@field knockbackSpeed? number Knockback speed applied by the damage source.
---@field x number Source X position.
---@field y number Source Y position.
---@field tags string[] Source damage tags.

---@class HurtBox
---@field owner Soul Owning soul.
---@field radius number Hurt radius in pixels.
---@field offsetX number Horizontal offset from owner.
---@field offsetY number Vertical offset from owner.
---@field damageTags string[] Accepted damage tags.
local HurtBox = {}
HurtBox.__index = HurtBox

-- TODO: refactor into own DamageTags module, and rethink design because it's really more of a "damage source tag"
-- Which gets confusing when one Soul needs the tag to give that damage, the receiver of the damage needs the same tag
-- in their damage opts. Somehow feels wrong that the same tag defines both the given damage type and received damage type.
-- The damage types to which the hurtbox is succeptible.
---@type table<string, string>
HurtBox.DAMAGE_TAGS = {
	PLAYER_ATTACK = "playerAttack",
	ENEMY_ATTACK = "enemyAttack",
	ENVIRONMENT = "environmentDamage",
}

---@type table<string, boolean>
local VALID_DAMAGE_TAGS = {}
for _, tag in pairs(HurtBox.DAMAGE_TAGS) do
	VALID_DAMAGE_TAGS[tag] = true
end

---@param tag string
---@return nil
local function assertValidDamageTag(tag)
	assert(VALID_DAMAGE_TAGS[tag], "Invalid hurtbox damage tag: " .. tostring(tag))
end

---@param source Soul|Husk
---@return boolean
function HurtBox:acceptsDamageFrom(source)
	for _, acceptedTag in ipairs(self.damageTags) do
		for _, sourceTag in ipairs(source.damageTags or {}) do
			if sourceTag == acceptedTag then
				return true
			end
		end
	end

	return false
end

---@param source Soul|Husk
---@param collider collider
---@return DamageHit
local function makeDamageHit(source, collider)
	local x, y = source:getPosition()

	return {
		source = source,
		collider = collider,
		damage = source.damage or 1,
		knockbackSpeed = source.knockbackSpeed,
		x = x,
		y = y,
		tags = source.damageTags or {},
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
		assertValidDamageTag(tag)
		table.insert(self.damageTags, tag)
	end

	return self
end

return HurtBox
