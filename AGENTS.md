# AGENTS.md

Guidelines for AI coding agents working on this LOVE 2D game project.

## Project Overview

- **Type**: LOVE 2D (Lua) game engine project
- **LOVE Version**: 11.5
- **Style**: Game Boy Advance aesthetic (240x160 virtual resolution scaled to 1080x720)
- **Physics**: Box2D via love.physics

## Build/Run/Test Commands

### Running the Game

```bash
# Run from project root
love .

# Run with console output for debugging
love . 2>&1 | tee debug.log
```

### Testing

No test framework is currently set up. The knife test library is available at `lib/knife/test.lua` for future use:

```bash
# When tests are added, run a single test file:
lua lib/knife/test.lua tests/test_player.lua

# Run all tests (when implemented):
lua lib/knife/test.lua tests/
```

### Packaging

```bash
# Create distributable .love file
zip -r game.love . -x "*.git*" "*.DS_Store" "AGENTS.md"
```

## Project Structure

```
lua-boy-advance/
├── main.lua              # Entry point (love.load, love.update, love.draw)
├── conf.lua              # LOVE configuration
├── src/                  # Source code
│   ├── Deps.lua          # Centralized dependency loading (globals)
│   ├── constants.lua     # Global constants
│   ├── Collision.lua     # Physics collision utilities
│   ├── entity/           # Game entities
│   │   ├── Entity.lua    # Base entity class
│   │   └── Player.lua    # Player entity (extends Entity)
│   ├── state/            # Game state management
│   │   ├── BaseState.lua
│   │   ├── StateMachine.lua
│   │   ├── StartState.lua
│   │   └── PlayState.lua
│   └── world/            # World/level management
├── lib/                  # Third-party libraries (do not modify)
├── art/                  # Graphics assets (.png)
├── fonts/                # Font files (.ttf)
└── maps/                 # Tiled map files (.tmx, .lua)
```

## Code Style Guidelines

### Indentation and Formatting

- **Indentation**: Use TABS (not spaces)
- **String quotes**: Double quotes preferred, especially for user-facing text
- **Line length**: Keep reasonable (~100 chars max)
- **Spacing**: Space after commas, around operators; no space before function params

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Modules/Classes | PascalCase | `Player`, `StateMachine` |
| Global variables | PascalCase | `Camera`, `World`, `Map` |
| Global tables | G-prefix PascalCase | `GFonts`, `GArt`, `GStateMachine` |
| Constants | SCREAMING_SNAKE_CASE | `VIRTUAL_WIDTH`, `KEY_UP` |
| Local variables | camelCase | `moveUp`, `isMoving`, `centerX` |
| Instance methods | PascalCase with colon | `self:MovePlayer()` |

### Module/Class Definition Pattern

Use metatables for classes (not lib/class.lua):

```lua
-- Standard module pattern
local ModuleName = {}
ModuleName.__index = ModuleName

function ModuleName.new(def)
    local self = setmetatable({}, ModuleName)
    -- Initialize properties from def table
    return self
end

function ModuleName:instanceMethod()
    -- Use self
end

return ModuleName
```

### Inheritance Pattern

```lua
local Entity = require("src.entity.Entity")

local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Entity })

function Player.new(def)
    return Entity.new(def, Player)
end

function Player:createCollision()
    Entity.createCollision(self)  -- Call parent method
    -- Additional Player-specific logic
end

return Player
```

### Import/Require Conventions

1. All shared dependencies go in `src/Deps.lua`
2. Use dot notation for paths: `require("src.entity.Player")`
3. Local requires at top of file for non-global dependencies:
   ```lua
   local BaseState = require("src.state.BaseState")
   ```

### Type Annotations

Use LuaLS annotations for public APIs:

```lua
---@class Collision
---@field body love.Body
---@field shape love.Shape

---Create a rectangle collider.
---@param world love.World
---@param x number Center X position
---@param y number Center Y position
---@param w number Width in pixels
---@param h number Height in pixels
---@param bodyType? love.BodyType Body type (default "static")
---@return Collision
function Collision.newRectangle(world, x, y, w, h, bodyType)
```

### Error Handling

- Use assertions for invariants: `assert(self.states[state])`
- Use default values with `or`: `bodyType = bodyType or "static"`
- Document optional params with `?` in annotations

### Comments

- Use `-- ` for inline comments
- Use `---` for LuaLS documentation
- Use `-- TODO:` or `-- TODO::` for todos
- Explain non-obvious logic, especially for future refactoring

### Table Formatting

```lua
-- Inline for simple tables
local t = { x = 1, y = 2 }

-- Multi-line for complex tables with trailing comma
self.player = Player.new({
    x = 180,
    y = 200,
    width = 14,
    height = 17,
})
```

## Key Patterns

### Global State

Heavy use of globals for shared resources (defined in `src/Deps.lua`):
- Libraries: `Anim8`, `HumpCamera`, `Push`, `Tiled`, `Timer`
- Game state: `Camera`, `Map`, `World`, `GStateMachine`, `KeyPress`
- Assets: `GFonts`, `GArt`

### State Machine Pattern

States inherit from `BaseState` and implement:
- `enterState(options)` - Called when entering the state
- `exitState()` - Called when leaving the state
- `update(dt)` - Called every frame
- `draw()` - Called every frame for rendering

### Input Handling

- `love.keyboard.wasPressed(key)` - Check if key was pressed this frame
- `love.keyboard.isDown(key)` - Check if key is currently held
- `KeyPress.order` - Stack tracking directional input priority

### Physics/Collision

- Box2D world with zero gravity: `love.physics.newWorld(0, 0)`
- Use `Collision` module factory methods: `Collision.newRectangle()`, `Collision.newOctagon()`
- Debug rendering: `Collision.drawAll(World, alpha)`

## Third-Party Libraries (lib/)

| Library | Purpose |
|---------|---------|
| anim8 | Sprite animation |
| camera (HUMP) | Camera management |
| push | Resolution scaling |
| sti | Tiled map loading |
| knife/timer | Timer/tweening |

Do not modify files in `lib/` - these are external dependencies.
