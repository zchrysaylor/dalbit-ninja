# AGENTS.md

Guidelines for AI coding agents working on this LOVE 2D game project.

## Project Overview

- **Type**: LOVE 2D (Lua) game project
- **LOVE Version**: 11.5
- **Style**: GBA-inspired top-down game with a low-resolution virtual screen scaled up via `push`
- **Virtual Resolution**: `192x128`
- **Window Resolution**: `1080x720`
- **Physics**: Box2D via `love.physics`
- **Architecture**: Global dependency loader in `src/deps.lua`, stack-based game states, per-entity state machines, event-driven cross-system communication via `Herald`

## Build / Run / Test Commands

```bash
# Run from project root
love .

# Run with console output for debugging
love . 2>&1 | tee debug.log

# Create distributable .love file
zip -r game.love . -x "*.git*" "*.DS_Store" "AGENTS.md"
```

### Testing

There are currently no tests or `tests/` directory in the repo. Do not attempt to write tests unless asked.

## Project Structure

```
lua-boy-advance/
├── main.lua                     # LOVE entry point; bootstraps globals and state stack
├── conf.lua                     # LOVE configuration (version, disabled modules, highdpi)
├── src/
│   ├── deps.lua                 # Centralized global dependency loading + asset/theme setup
│   ├── constants.lua            # Global resolution, input, and timing constants
│   ├── util.lua                 # Small shared helpers like safeDraw
│   ├── engine/
│   │   ├── collision.lua        # Collision queries + debug drawing helpers
│   │   ├── input.lua            # Input manager + state-scoped input event dispatch
│   │   ├── lens.lua             # Camera module; owns HUMP camera instance
│   │   ├── herald.lua           # Lightweight pub/sub event bus
│   │   ├── events.lua           # Centralized event name constants
│   │   ├── physics.lua          # Physics wrapper + collider factory/tag system
│   │   ├── dbg.lua              # Debug overlay and collider/query rendering
│   │   └── transition.lua       # Fade transition overlay driven by Flux
│   ├── graphics/
│   │   ├── nineSlice.lua        # Nine-slice panel renderer for UI
│   │   └── theme.lua            # Global UI theme built from art and fonts
│   ├── realm/
│   │   ├── Realm.lua            # World/map controller (map, entities, camera, physics)
│   │   ├── SoulSpawner.lua      # Spawn soul NPCs from Tiled object layers
│   │   ├── HuskSpawner.lua      # Spawn interactable/static props from Tiled object layers
│   │   ├── WallSpawner.lua      # Spawn wall colliders from Tiled object layers
│   │   ├── WarpSpawner.lua      # Spawn warp colliders and resolve overlap checks
│   │   └── mapTransitions.lua   # Warp-name -> destination map/spawn lookup
│   ├── state/
│   │   ├── BaseState.lua        # No-op base state with lifecycle hooks
│   │   ├── StateMachine.lua     # Factory-based single-active-state machine
│   │   ├── StateStack.lua       # Stack of active game states; top updates, all draw
│   │   ├── game/
│   │   │   ├── StartState.lua   # Title screen
│   │   │   ├── PlayState.lua    # Main gameplay state
│   │   │   └── MenuState.lua    # Overlay menu panel drawn on top of play
│   │   └── vessel/
│   │       ├── husk/
│   │       │   └── HuskIdleState.lua
│   │       └── soul/
│   │           ├── SoulIdleState.lua
│   │           ├── SoulWanderState.lua
│   │           ├── SoulChaseState.lua
│   │           ├── SoulReturnState.lua
│   │           └── player/
│   │               ├── PlayerIdleState.lua
│   │               └── PlayerWalkState.lua
│   └── vessel/
│       ├── Vessel.lua           # Physics body composition layer around colliders
│       ├── husk/
│       │   └── Husk.lua         # Interactable/static world props
│       └── soul/
│           ├── Soul.lua         # Base moving entity with animations + AI helpers
│           └── Player.lua       # Player soul subclass with 8-dir anims + interaction
├── lib/                         # Third-party libraries; do not modify
├── art/                         # Sprites, UI panels, tilesets
├── fonts/                       # TTF fonts
├── maps/                        # Tiled sources and exported Lua maps
└── tests/                       # Not present yet; new tests should go here
```

## Code Style Guidelines

### Indentation and Formatting

- **Indentation**: Tabs, not spaces
- **String quotes**: Double quotes preferred
- **Line length**: Keep lines reasonably compact, around ~100 chars when practical
- **Spacing**: Use spaces after commas and around operators

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `Soul`, `Player`, `Realm`, `StateStack` |
| Utility modules | camelCase | `collision`, `physics`, `input`, `theme` |
| Global runtime instances | PascalCase with prefixes where established | `GStateStack`, `Input`, `Lens` |
| Global asset/theme tables | G-prefix PascalCase | `GArt`, `GFonts`, `GTheme` |
| Constants | SCREAMING_SNAKE_CASE | `VIRTUAL_WIDTH`, `KEY_MENU`, `FADE_RATE` |
| Local variables | camelCase | `dirX`, `idleTimer`, `triggeredWarp` |
| Instance methods | PascalCase colon-syntax for classes in this codebase | `self:changeState()`, `self:syncPosition()` |
| Utility functions | camelCase dot-syntax | `collision.isColliding()`, `util.safeDraw()` |

Follow the file you are editing. Despite the convention note above, some existing instance methods also use lower camel case like `changeState` and `syncPosition`; preserve the surrounding style instead of renaming APIs for consistency churn.

### Module / Class Definition Pattern

Classes use raw metatables.

```lua
---@class MyClass
local MyClass = {}
MyClass.__index = MyClass

---@return MyClass
function MyClass.new()
	local self = setmetatable({}, MyClass)
	return self
end

return MyClass
```

Utility modules are function containers with no instances:

```lua
---@class mymodule
local mymodule = {}

---@param x number
---@return number
function mymodule.utilityFunction(x)
	return x * 2
end

return mymodule
```

### Inheritance and Composition Patterns

**Composition: Soul and Husk have-a Vessel**

`Soul` and `Husk` each create a `Vessel` internally and expose `self.vessel` plus `self.collider` as a convenience reference.

```lua
self.vessel = Vessel.new(vesselOpts)
self.collider = self.vessel.collider
self.collider.owner = self
```

**Delegating constructor** (`Soul -> Player`):

```lua
local Soul = require("src.vessel.soul.Soul")
local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Soul })

function Player.new(def)
	local self = Soul.new(def, Player)
	self.collider:setLinearDamping(0)
	return self
end
```

**BaseState constructor**:

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

### Import / Require Conventions

1. Shared systems are loaded in `src/deps.lua` and assigned to globals.
2. File-local dependencies are still `require`d explicitly at the top of the file.
3. Use dot notation for requires: `require("src.state.game.PlayState")`
4. `main.lua` requires `src.deps`, then uses globals for the rest of boot.
5. `src/deps.lua` load order matters in a few places:
   `Debug` depends on `Herald` and `Events`, and `Transition` depends on `Flux` and `Util`.

### Type Annotations

Use LuaLS annotations (`---@`) on public modules, classes, methods, aliases, and important fields.

Common patterns in this repo:

```lua
---@class MenuState : BaseState
---@field stateName string
local MenuState = {}
```

```lua
---@alias StateInputAction
---| "interact"
---| "toggle_menu"
---| "toggle_pause"
```

### Error Handling

- Use `assert()` for invariants and programmer errors
- Use `or` defaults for optional fields where appropriate
- Mark optional params with `?` in LuaLS annotations
- Avoid `pcall`/`xpcall` in game runtime code

### Comments

- Use `-- ` for normal comments
- Use `---` for LuaLS docs directly above the item
- Use `-- TODO:` for follow-up work
- Comment Box2D quirks, render ordering, or event/lifecycle subtleties when not obvious

### Table Formatting

```lua
local t = { x = 1, y = 2 }

self.player = Player.new({
	x = 152,
	y = 136,
	width = 16,
	height = 17,
	speed = 0.8,
	scale = 1,
	spriteSheet = GArt["sprite-player"],
	physics = self.physics,
})
```

Prefer trailing commas in multi-line constructor/config tables.

## Key Architectural Patterns

### Global State and Bootstrapping

`src/deps.lua` is intentionally the central bootstrap for globals. It loads third-party libs, engine modules, entities, states, assets, and the UI theme.

Current important globals include:

- **Libraries**: `Anim8`, `Flux`, `Push`, `Tiled`
- **Core systems**: `Collision`, `Events`, `Input`, `Lens`, `Physics`, `Herald`, `Debug`, `Transition`
- **UI**: `NineSlice`, `GTheme`
- **Classes**: `Vessel`, `Soul`, `Husk`, `Player`, `Realm`
- **Spawners / data**: `MapTransitions`, `WallSpawner`, `WarpSpawner`, `SoulSpawner`, `HuskSpawner`
- **States**: `StateStack`, `StateMachine`, `StartState`, `PlayState`, `MenuState`, and the vessel states
- **Assets**: `GArt`, `GFonts`
- **Runtime state**: `GStateStack`

### Game State Model

Top-level game flow now uses `StateStack`, not a single `GStateMachine`.

- `GStateStack:push(StartState.new())` boots the title screen
- Only the top state updates
- All stacked states draw from bottom to top
- Overlay states like `MenuState` render on top of `PlayState` while gameplay update is paused implicitly because only the top state updates

Use `StateMachine` for entity-local behavior and `StateStack` for game/screen layering.

### State Lifecycle

`BaseState` exposes these hooks:

- `enterState(opts)`
- `exitState()`
- `update(dt)`
- `postPhysicsUpdate(dt)`
- `draw()`

`StateMachine` stores factory functions, not instances. On transition it runs:

`exitState() -> factory() -> enterState(opts)`

For entity states, add an immediate `return` after a `changeState(...)` call unless follow-up behavior is explicitly required.

### Input Handling

Input is centralized in `src/engine/input.lua`.

- `love.keypressed` forwards into `Input:keyPressed(key)`
- Frame-local presses are stored in `Input.keysPressed`
- `Input:wasPressed(key)` is the single-frame press query
- `Input.getDirection()` returns `dirX`, `dirY`, `isMoving`
- Input is routed to the top stacked state through event names built from `Events.STATE_INPUT_PREFIX .. topState.stateName`

### Events and Pub/Sub

Cross-system communication uses `Herald`.

- `Herald.hearken(name, callback)` subscribes and returns an unsubscriber
- `Herald.decree(name, ...)` dispatches synchronously
- Returning `false` from a handler stops propagation
- `Herald.muster()` groups subscriptions so a state/system can clean them up together with `unhearkenAll()`

Current built-in events are defined in `src/engine/events.lua`:

### Physics and Collision

- The world is created per `Realm` via `love.physics.newWorld(0, 0)`
- `Physics.new(world)` wraps the Box2D world
- `Vessel` owns the collider/body abstraction for moving/static world objects
- Collider tagging is used heavily, including tags like `"soul"`, `"husk"`, and `"interactable"`
- `Collision.isColliding(c1, c2)` is used for collider overlap checks
- `Collision.queryCircleArea(...)` is used for front-of-player interaction queries
- Player movement uses physics velocity
- AI souls also set Box2D velocity, then validate motion in `postPhysicsUpdate`
- Debug rendering uses `Debug.drawAll(world, alpha)`, which draws both colliders and query shapes

### Realm / Map System

`Realm` owns the current map, current world physics instance, map-scoped colliders/entities, and the persistent player.

`Realm:loadMap(mapName, destX, destY)` does the following:

- Destroys current walls, warps, souls, and husks
- Loads the new STI map from `maps/<name>.lua`
- Spawns objects from object layers if present
- Teleports the player when destination coordinates are provided
- Re-snaps the camera with `Lens.follow(...)`

Warp destination lookup lives in `src/realm/mapTransitions.lua`.

### Souls, AI, and Interaction

`Soul` is the base moving entity.

- Owns animations and an entity-local `StateMachine`
- Supports AI config via `self.ai`
- Tracks `previousX/previousY` for post-physics blocked-movement checks
- Uses helper methods like `setAIMoveVector`, `chooseAIWanderDirection`, `setAIChaseTarget`, and `canDetectAIChaseTarget`

`Player` extends `Soul` and overrides:

- animation setup for 8 directions
- state machine setup
- directional animation syncing
- `interact()` to query nearby interactables in front of the persisted facing direction

### Husks and Interactables

`Husk` is a lighter world-entity type for props or interactables.

- Uses a `Vessel` with a static body
- Can be animated or static depending on `animOpts`
- Owns its own state machine
- Supports an overridable `interact()` method

Current concrete husk content is spawned in `HuskSpawner`.

### Rendering Pipeline

Current high-level draw order:

```text
love.draw()
  Push:start()
  GStateStack:draw()
    StartState or PlayState
    PlayState:draw()
      Realm:draw()
        love.graphics.clear(bgColor)
        Lens.attach(...)
          map layers
          souls
          husks
          player
          Debug.drawAll(...)   -- when enabled
        Lens.detach()
      Transition.draw()        -- after realm so fade overlays whole screen
      MenuState:draw()         -- if stacked on top
  Push:finish()
  Debug.drawFPS()              -- outside Push when debug is enabled
```

When temporarily changing graphics state, use `Util.safeDraw(function() ... end)` so fonts, colors, and transforms do not leak.

### Camera

- `Lens` owns the HUMP camera instance; do not create other camera instances ad hoc
- `Lens.follow(player, map)` is called every `Realm:update(dt)` and once after map load to avoid transition-time camera mismatch
- `Realm:draw()` wraps world drawing in `Lens.attach(...)` / `Lens.detach()`

### UI Theme

UI styling has a dedicated theme layer:

- `src/graphics/nineSlice.lua` provides resizable 9-slice panels
- `src/graphics/theme.lua` builds `GTheme` from `GArt` and `GFonts`
- `MenuState` uses `GTheme.panels`, `GTheme.fonts`, and `GTheme.colors`

If you add more UI, prefer extending `GTheme` rather than hardcoding repeated panel/font/color choices in each state.

## Third-Party Libraries

| Library | Global | Purpose |
|---------|--------|---------|
| anim8 | `Anim8` | Sprite sheet animation |
| push | `Push` | Virtual resolution scaling |
| sti | `Tiled` | Tiled map loading |
| flux | `Flux` | Tweens and transitions |
| hump camera | internal to `Lens` | Camera follow/clamping |

Do not modify files under `lib/` unless the user explicitly asks for dependency work.
