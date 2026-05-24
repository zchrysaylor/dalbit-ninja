---
name: luals-annotations
description: Adds or cleans up LuaLS annotations in Lua code using the project's idiomatic documentation style. Use when the user specifically asks to create, update, clean up, or review LuaLS annotations or `---@` docs.
---

# LuaLS Annotation Cleanup

## Quick start

When asked to add or clean up annotations, inspect the surrounding module style first, then add only useful LuaLS annotations for public APIs and important data shapes.

Checklist:

- Annotate public modules, classes, methods, aliases, and important fields with `---@`.
- Prefer primitive types directly (`string`, `boolean`, `number`) over aliases/classes that only wrap one primitive.
- Use custom annotations for table-shaped data (`SoulDef`) or long/ugly field types that become clearer behind an alias (`PlayerDirection`).
- Add a brief one-sentence descriptor above every annotated method.
- Reuse existing descriptors for the same method/field concepts across files.
- Do not repeat inherited field annotations in child classes unless the child changes the field type or meaning.
- Run `luac -p` on changed Lua files after edits.

## Descriptor rules

Every annotated method needs a concise descriptor:

```lua
---Create a new projectile.
---@param def ProjectileDef Projectile definition.
---@return Projectile
function Projectile.new(def)
    -- ...
end
```

Inline field descriptors should be stable across all classes and reused when the field means the same thing:

```lua
---@field physics Physics Physics world wrapper.
---@field collider Collider Physics collider wrapper.
```

Before inventing wording, search existing annotations for that method or field name. Prefer exact reuse over near-synonyms.

## Classes and modules

Use class annotations for public class-like tables:

```lua
---@class Projectile
---@field x number World x-coordinate.
---@field y number World y-coordinate.
---@field physics Physics Physics world wrapper.
local Projectile = {}
Projectile.__index = Projectile
```

Do not create aliases/classes for single primitives:

```lua
-- Avoid:
---@alias ProjectileId string

-- Prefer:
---@field projectileId string Projectile identifier.
```

For child classes, annotate inheritance and only add fields introduced or redefined by the child. Do not duplicate parent fields just to make the child annotation look complete:

```lua
---@class EnemyProjectile : Projectile
---@field target Soul Target soul.
local EnemyProjectile = {}
EnemyProjectile.__index = EnemyProjectile
setmetatable(EnemyProjectile, { __index = Projectile })
```

Avoid redundant inherited fields:

```lua
-- Avoid: x, y, and physics already belong to Projectile.
---@class EnemyProjectile : Projectile
---@field x number World x-coordinate.
---@field y number World y-coordinate.
---@field physics Physics Physics world wrapper.
---@field target Soul Target soul.
```

## Table-shaped definitions

Use named table types when reused or semantically important:

```lua
---@class ProjectileDef
---@field x number Initial world x-coordinate.
---@field y number Initial world y-coordinate.
---@field speed? number Movement speed in pixels per second.
---@field damage? number Damage dealt on impact.
```

Use aliases for long or repetitive union/function/table types:

```lua
---@alias PlayerDirection "up"|"down"|"left"|"right"|"up-left"|"up-right"|"down-left"|"down-right"
```

## Constructors with subclass metatables

If a constructor accepts a subclass metatable, use a constrained generic and return that generic:

```lua
---Create a new base state.
---@generic T : BaseState
---@param subclass? T Subclass metatable.
---@return T
function BaseState.new(subclass)
    local self = setmetatable({}, subclass or BaseState)
    return self
end
```

Use the project's parent-constructor pattern for subclasses:

```lua
---Create a new play state.
---@return PlayState
function PlayState.new()
    local self = BaseState.new(PlayState)
    return self
end
```

## `opts` parameters

If `opts` is accepted for legacy/API consistency but fields are not currently read, keep it broad:

```lua
---Enter the state.
---@param opts? table Optional options.
function MenuState:enterState(opts)
    -- opts intentionally unused
end
```

If specific fields are read, annotate them inline or with a named options type:

```lua
---Create a new collider.
---@param opts? { tag?: string, isSensor?: boolean, fixedRotation?: boolean } Collider options.
---@return Collider
function physics:collider(opts)
    -- reads opts.tag, opts.isSensor, opts.fixedRotation
end
```

For reused or larger option shapes, use a named class:

```lua
---@class VesselOptions
---@field tag? string Collider tag.
---@field radius? number Collider radius.
---@field fixedRotation? boolean Whether the body prevents rotation.

---Create a new vessel.
---@param opts? VesselOptions Vessel options.
---@return Vessel
function Vessel.new(opts)
    -- ...
end
```

## Cleanup workflow

1. Read the full file and nearby related files to learn naming, descriptors, and existing types.
2. Remove primitive-only aliases/classes unless they improve an ugly union or repeated signature.
3. Add missing method descriptors, params, returns, class fields, and important table types.
4. Remove child-class field annotations that simply repeat inherited parent fields.
5. Normalize repeated field descriptions to existing canonical wording.
6. Avoid large annotation rewrites that do not improve public API clarity.
7. Run `luac -p path/to/file.lua` for each changed Lua file.
