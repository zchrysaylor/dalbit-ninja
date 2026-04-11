# AGENTS.md

Guidelines for AI coding agents working on this LOVE 2D game project.

## Project Overview

- **Type**: LOVE 2D (Lua) game engine project
- **LOVE Version**: 11.5
- **Style**: Game Boy Advance aesthetic (240x160 virtual resolution scaled to 1080x720)
- **Physics**: Box2D via love.physics (zero gravity top-down world)

## Build/Run/Test Commands

```bash
# Run from project root
love .

# Run with console output for debugging
love . 2>&1 | tee debug.log

# Create distributable .love file
zip -r game.love . -x "*.git*" "*.DS_Store" "AGENTS.md"
```

### Testing

No test framework is currently set up. The knife test library is available at `lib/knife/test.lua`:

```bash
# Run a single test file (when tests are added):
lua lib/knife/test.lua tests/test_player.lua

# Run all tests (when implemented):
lua lib/knife/test.lua tests/
```

There is no `tests/` directory yet. New tests should go there and follow the knife test API.

## Project Structure

```
lua-boy-advance/
├── main.lua              # Entry point: love.load/update/draw + input callbacks
├── conf.lua              # LOVE configuration (window, version)
├── src/
│   ├── deps.lua          # Centralized global dependency loading
│   ├── constants.lua     # Global constants (resolution, key bindings, rates)
│   ├── engine/
│   │   ├── collision.lua # Box2D collision factory + debug rendering
│   │   ├── input.lua     # Directional input reading (getDirection)
│   │   ├── lens.lua      # Camera module: owns HUMP instance, attach/detach/follow/setZoom
│   │   ├── physics.lua   # isColliding() utility
│   │   └── signal.lua    # Pub/sub event bus
│   ├── realm/
│   │   ├── Realm.lua         # World/level controller (map, camera, entities)
│   │   ├── SoulSpawner.lua   # Spawn Soul entities from Tiled object layers
│   │   ├── WallSpawner.lua   # Spawn wall colliders from Tiled object layers
│   │   └── WarpSpawner.lua   # Spawn warps + handle map transitions
│   ├── state/
│   │   ├── BaseState.lua     # No-op base: enterState, exitState, update, draw
│   │   ├── StateMachine.lua  # Generic state machine (changeState, update, draw)
│   │   ├── StartState.lua    # Title screen with fade-in/out
│   │   ├── PlayState.lua     # Main gameplay (pause, fade, realm delegation)
│   │   └── vessel/soul/
│   │       ├── SoulIdleState.lua   # NPC idle: paused animation
│   │       ├── SoulWalkState.lua   # NPC walk: direct position update + AI stub
│   │       └── player/
│   │           ├── PlayerIdleState.lua  # Player idle: detect input to walk
│   │           └── PlayerWalkState.lua  # Player walk: physics velocity + 8-dir anim
│   └── vessel/soul/
│       ├── Soul.lua      # Base entity class (animations, collision, state machine)
│       └── Player.lua    # Player extends Soul (8-dir movement, physics-based)
├── lib/                  # Third-party libraries — do not modify
├── art/                  # Sprite sheets and tilesets (.png)
├── fonts/                # Pixel fonts (.ttf)
└── maps/                 # Tiled map files (.tmx source + .lua export)
```

## Code Style Guidelines

### Indentation and Formatting

- **Indentation**: Tabs (not spaces) — enforced throughout all source files
- **String quotes**: Double quotes preferred (`"idle"`, `"map-hometown"`)
- **Line length**: Keep reasonable (~100 chars max)
- **Spacing**: Space after commas and around operators; no space before function call parens

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `Soul`, `Player`, `StateMachine`, `Realm` |
| Utility modules | camelCase | `collision`, `physics`, `input`, `signal` |
| Global variables | PascalCase | `Camera`, `GStateMachine`, `Input` |
| Global asset tables | G-prefix PascalCase | `GFonts`, `GArt` |
| Constants | SCREAMING_SNAKE_CASE | `VIRTUAL_WIDTH`, `KEY_UP`, `FADE_RATE` |
| Local variables | camelCase | `moveUp`, `isMoving`, `centerX` |
| Instance methods | PascalCase colon-syntax | `self:MovePlayer()`, `self:AnimatePlayer()` |
| Static/utility functions | camelCase dot-syntax | `collision.newRectangle()`, `physics.isColliding()` |

### Module/Class Definition Pattern

**Classes** use raw metatables. **Do not use `lib/class.lua`** — it is present but intentionally unused.

```lua
-- Class pattern (PascalCase)
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new(def)
    local self = setmetatable({}, MyClass)
    -- initialize from def table
    return self
end

function MyClass:instanceMethod()
    -- use self
end

return MyClass
```

**Utility modules** are simple function containers with no instances:

```lua
-- Module pattern (camelCase)
---@module mymodule
local mymodule = {}

---@param x number
---@return number
function mymodule.utilityFunction(x)
    return x * 2
end

return mymodule
```

### Inheritance Patterns

Three patterns are used — choose the one that matches the existing hierarchy:

**Pattern 1 — Delegating constructor** (Soul → Player):
```lua
local Soul = require("src.vessel.soul.Soul")
local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Soul })

function Player.new(def)
    return Soul.new(def, Player)  -- Soul.new does setmetatable({}, subclass or Soul)
end

function Player:createCollision(world)
    Soul.createCollision(self, world)  -- explicit super call
    -- Player-specific additions
end
```

**Pattern 2 — BaseState constructor** (state classes):
```lua
local BaseState = require("src.state.BaseState")
local PlayState = {}
PlayState.__index = PlayState
setmetatable(PlayState, { __index = BaseState })

function PlayState.new()
    local self = BaseState.new(PlayState)
    return self
end
```

**Pattern 3 — Re-setmetatable** (deeper state inheritance, e.g. PlayerIdleState):
```lua
function PlayerIdleState.new(player)
    local self = SoulIdleState.new(player)  -- create with parent metatable
    setmetatable(self, PlayerIdleState)     -- then override to child metatable
    return self
end
```

### Import/Require Conventions

1. All shared dependencies are loaded once in `src/deps.lua` and assigned to globals — no import needed in consuming files.
2. Non-global, file-local dependencies are `require`d at the top of each file:
   ```lua
   local BaseState = require("src.state.BaseState")
   local Soul = require("src.vessel.soul.Soul")
   ```
3. Always use **dot notation** (not slashes): `require("src.vessel.soul.Player")`
4. `main.lua` only requires `src.deps` — everything else is accessed via globals.

### Type Annotations

Use LuaLS (`---@`) annotations on all public APIs and definitions:

**Classes** use `---@class` with field annotations:
```lua
---@class PlayerIdleState : BaseState
---@field soul Player
local PlayerIdleState = {}
PlayerIdleState.__index = PlayerIdleState
```

**Utility modules** use `---@module`:
```lua
---@module collision
local collision = {}

---Create a rectangle collider.
---@param world love.World
---@param x number Center X position
---@param y number Center Y position
---@param w number Width in pixels
---@param h number Height in pixels
---@param bodyType? love.BodyType Body type (default "static")
---@return CollisionData
function collision.newRectangle(world, x, y, w, h, bodyType)
```

### Error Handling

- Use `assert()` for invariants: `assert(self.states[state])`
- Use `or` for defaults: `bodyType = bodyType or "static"`, `alpha = alpha or 1`
- Mark optional params with `?` in LuaLS annotations
- No `pcall`/`xpcall` in game code — only in test infrastructure

### Comments

- `-- ` for inline and section comments
- `---` for LuaLS documentation (directly above the item)
- `-- TODO:` or `-- TODO::` for todos (both forms appear in the codebase)
- Explain non-obvious logic — especially Box2D quirks and LOVE rendering order

### Table Formatting

```lua
-- Inline for simple tables
local t = { x = 1, y = 2 }

-- Multi-line for constructor defs — trailing comma required
self.player = Player.new({
    x = 160,
    y = 200,
    width = 16,
    height = 16,
    speed = 0.8,
    spriteSheet = GArt["sprite-player"],
    world = self.world,
})
```

## Key Architectural Patterns

### Global State

All major systems are globals defined in `src/deps.lua`. This is intentional — avoids passing references everywhere.

- **Libraries**: `Anim8`, `Push`, `Tiled`, `Flux`
- **Instances**: `GStateMachine`
- **Assets**: `GFonts`, `GArt`
- **Classes**: `Soul`, `Player`, `Realm`, `SoulSpawner`, `WallSpawner`, `WarpSpawner`
- **Utility modules**: `Collision`, `Lens`, `Physics`, `Input`, `Signal`
- **State classes**: `StateMachine`, `BaseState`, `StartState`, `PlayState`, `SoulIdleState`, `SoulWalkState`, `PlayerIdleState`, `PlayerWalkState`

### State Machine Pattern

Two-tier state machine:
1. **Top-level** `GStateMachine` — manages game screens (`"start"` / `"play"`)
2. **Per-entity** `stateMachine` inside each `Soul` — manages entity states (`"idle"` / `"walk"`)

`StateMachine` stores factory functions (not instances) and calls them fresh on each `changeState`. Lifecycle: `exitState()` → factory() → `enterState(args)`. States inherit from `BaseState` and implement:
- `enterState(args)` — setup on entry
- `exitState()` — teardown on exit
- `update(dt)` — per-frame logic
- `draw()` — per-frame rendering

### Input Handling

- `love.keyboard.wasPressed(key)` — single-frame press check (extension added in `main.lua`)
- `love.keyboard.isDown(key)` — continuous hold check
- `Input.getDirection()` — returns `dirX`, `dirY`, `isMoving` from directional key state

### Physics and Collision

- Box2D world with zero gravity: `love.physics.newWorld(0, 0)`
- Use `Collision` factory methods: `Collision.newRectangle()`, `Collision.newOctagon()`
- Player uses **physics velocity** (`body:setLinearVelocity()`); NPCs use **direct position mutation**
- Debug collision rendering: `Collision.drawAll(World, alpha)` — toggled with `KEY_DEBUG` (`.`)
- Box2D `setUserData()` stores metadata (e.g. warp destination) on fixtures for collision callbacks

### Rendering Pipeline

```
love.draw()
  Push:start()
  GStateMachine:draw()
    PlayState:draw()
      Realm:draw()
        Lens.attach()            -- clips to virtual 240x160
          Map layer draws        -- "base", "ground", "building"
          NPC entity:draw()
          player:draw()
          Collision.drawAll()    -- debug only
        Lens.detach()
      Fade overlay rectangle     -- during map transitions
      Pause text overlay
  Push:finish()
```

### Camera

- `Lens` (`src/engine/lens.lua`) owns the HUMP camera instance — do not instantiate HUMP directly elsewhere
- `Lens.follow(player, map)` must be called every frame including during fades; it is called inside `Realm:update(dt)` for normal frames and once in `Realm:loadMap()` to snap the camera before any fade begins — if only called in `Realm:update`, the camera will be off-map until the fade completes
- `Lens.setZoom(n)` sets `cam.scale`; `Lens.follow` accounts for zoom in its map boundary clamping via `VIRTUAL_WIDTH / (2 * cam.scale)`

### Map / Warp System

- Maps are Tiled `.lua` exports loaded by STI (`Tiled("maps/name.lua")`)
- Object layers used: `"wall"`, `"warp"`, `"entity"` (spawning) + `"base"`, `"ground"`, `"building"` (rendering)
- `WarpSpawner` holds a `MAP_TRANSITIONS` lookup table (warp name → destination map + spawn coords)
- Warp collision checked each frame via `Physics.isColliding()`; triggers `Realm:loadMap()`
- `Realm:loadMap()` destroys all existing colliders before loading the new map

## Third-Party Libraries (lib/)

| Library | Global | Purpose |
|---------|--------|---------|
| anim8 | `Anim8` | Sprite sheet animation |
| push | `Push` | Virtual resolution scaling |
| sti | `Tiled` | Tiled map loading |
| flux | `Flux` | Tweens |

**Do not modify files in `lib/`** — these are external dependencies.
