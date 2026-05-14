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

---Query damaging colliders overlapping this hurtbox.
---@return collider[]
function HurtBox:query()
	local world = self.owner.collider.body:getWorld()
	local px, py = self.owner:getPosition()

	return Collision.queryCircleArea(world, px + self.offsetX, py + self.offsetY, self.radius, function(c)
		if c.owner == self.owner then
			return false
		end

		for _, tag in ipairs(self.damageTags) do
			if c:hasTag(tag) then
				return true
			end
		end

		return false
	end, 1)
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
