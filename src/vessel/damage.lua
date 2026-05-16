---@class DamageSourceConfig
---@field type string Damage type this source deals.
---@field amount? number Damage amount dealt. Defaults to 1.
---@field knockbackSpeed? number Knockback speed applied by this damage source.

---@class DamageSource
---@field type string Damage type this source deals.
---@field amount number Damage amount dealt.
---@field knockbackSpeed? number Knockback speed applied by this damage source.

---@class damage
local damage = {}

---Damage types describe what kind of damage a source deals and what kind of damage a hurtbox can receive.
---@type table<string, string>
damage.TYPES = {
    PLAYER_ATTACK = "playerAttack",
    ENEMY_ATTACK = "enemyAttack",
    ENVIRONMENT = "environmentDamage",
}

---@type table<string, boolean>
local VALID_TYPES = {}
for _, damageType in pairs(damage.TYPES) do
    VALID_TYPES[damageType] = true
end

---Assert that a damage type is registered; invalid types are data/setup errors.
---@param damageType string
---@return nil
function damage.assertValidType(damageType)
    assert(VALID_TYPES[damageType], "Invalid damage type: " .. tostring(damageType))
end

---Normalize an optional damage source config, asserting when a provided source is malformed.
---@param damageSource DamageSourceConfig?
---@return DamageSource?
function damage.normalizeSource(damageSource)
    if not damageSource then
        return nil
    end

    assert(damageSource.type, "DamageSource must have at least a type")
    damage.assertValidType(damageSource.type)

    return {
        type = damageSource.type,
        amount = damageSource.amount or 1,
        knockbackSpeed = damageSource.knockbackSpeed or 200,
    }
end

return damage
