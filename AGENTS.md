# AGENTS.md

Guidelines for AI coding agents working on this LOVE 2D game project.

## Project Overview

- **Type**: LOVE 2D (Lua) game project, version 11.5
- **Style**: GBA-inspired top-down game with a low-res camera framing that scales to the current window size via `View` and `Lens`
- **Physics**: Box2D via `love.physics`
- **Architecture**: Global dependency loader in `src/deps.lua`, stack-based game states, per-entity state machines, event-driven cross-system communication via `Herald`

## Build / Run / Test Commands

```bash
love .                                    # Run from project root
love . 2>&1 | tee debug.log              # Run with console output
luac -p path/to/file.lua                 # Check Lua syntax after changes
zip -r game.love . -x "*.git*" "*.DS_Store" "AGENTS.md"  # Distributable
```

No tests exist yet. Do not write tests unless asked. Always run `luac -p` on changed Lua files
after edits are complete to catch syntax errors before handing work back.

## Project Structure

```
dalbit-ninja/
├── main.lua
├── conf.lua
├── src/
│   ├── deps.lua
│   ├── constants.lua
│   ├── util.lua
│   ├── engine/
│   │   ├── collision.lua
│   │   ├── input.lua
│   │   ├── lens.lua
│   │   ├── view.lua
│   │   ├── herald.lua
│   │   ├── events.lua
│   │   ├── physics.lua
│   │   ├── dbg.lua
│   │   └── transition.lua
│   ├── graphics/
│   │   ├── nineSlice.lua
│   │   └── theme.lua
│   ├── realm/
│   │   ├── Realm.lua
│   │   ├── SoulSpawner.lua
│   │   ├── HuskSpawner.lua
│   │   ├── WallSpawner.lua
│   │   ├── WarpSpawner.lua
│   │   └── mapTransitions.lua
│   ├── state/
│   │   ├── BaseState.lua
│   │   ├── StateMachine.lua
│   │   ├── StateStack.lua
│   │   ├── game/
│   │   └── vessel/
│   └── vessel/
│       ├── Vessel.lua
│       ├── husk/
│       └── soul/
├── lib/                         # Third-party; do not modify
├── art/
├── fonts/
├── maps/
└── tests/
```

## Code Style Guidelines

### Formatting

- **Indentation**: Tabs, not spaces
- **String quotes**: Double quotes preferred
- **Line length**: ~100 chars when practical
- **Spacing**: Spaces after commas and around operators
- Prefer trailing commas in multi-line tables

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `Soul`, `Realm`, `StateStack` |
| Utility modules | camelCase | `collision`, `physics`, `input` |
| Global instances | PascalCase | `GStateStack`, `Input`, `Lens` |
| Global asset tables | G-prefix PascalCase | `GArt`, `GFonts`, `GTheme` |
| Constants | SCREAMING_SNAKE_CASE | `WINDOW_WIDTH`, `KEY_MENU` |
| Local variables | camelCase | `dirX`, `idleTimer` |
| Instance methods | colon-syntax | `self:changeState()` |
| Utility functions | dot-syntax | `collision.isColliding()` |

Follow the file you are editing. Some instance methods use lower camelCase; preserve surrounding style rather than renaming for consistency.

### Module / Class Definition Pattern

Classes use raw metatables:

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

### Inheritance Pattern

Subclasses delegate to parent constructors via a `subclass` parameter:

```lua
local Soul = require("src.vessel.soul.Soul")
local Player = {}
Player.__index = Player
setmetatable(Player, { __index = Soul })

function Player.new(def)
	local self = Soul.new(def, Player)
	return self
end
```

The same pattern applies to `BaseState` subclasses. `Soul` and `Husk` use composition: each creates a `Vessel` internally and exposes `self.vessel` and `self.collider`.

### Require Conventions

- Shared systems are loaded in `src/deps.lua` as globals
- File-local dependencies use `require` at the top: `require("src.state.game.PlayState")`
- Load order in `deps.lua` matters: `View` should be available before modules that size UI/overlays from the current window, `Debug` depends on `Herald`/`Events`, and `Transition` depends on `Flux`/`Util`

### Type Annotations

Use LuaLS annotations (`---@`) on public modules, classes, methods, aliases, and important fields. If a constructor accepts a `subclass` metatable, annotate with a constrained generic (`---@generic T : BaseState`).

- For `opts` parameters: use `---@param opts? table Optional options.` when the function accepts legacy or currently-unused options for API consistency/posterity, use an inline table type or named options type for `opts` when the function actually reads specific `opts` fields (for example `physics:collider` or `Vessel.new`).

### Error Handling

- `assert()` for invariants; `or` defaults for optional fields
- Mark optional params with `?` in annotations
- Avoid `pcall`/`xpcall` in game runtime code

### Comments

- `-- ` for normal comments; `---` for LuaLS docs
- `-- TODO:` for follow-up work
- Comment Box2D quirks, render ordering, or lifecycle subtleties when not obvious

## Key Architectural Patterns

### Globals

All globals are defined in `src/deps.lua`. Read it to see the current set. Convention: `G`-prefix for assets/runtime tables (`GArt`, `GStateStack`), PascalCase for systems and classes.

### Game State Model

- `StateStack` for game/screen layering (only top state updates; all draw bottom-to-top)
- `StateMachine` for entity-local behavior (stores factory functions, not instances)
- `BaseState` lifecycle hooks: `enterState(opts)`, `exitState()`, `update(dt)`, `postPhysicsUpdate(dt)`, `draw()`
- Every state module defines `STATE_NAME`. Use `self.stateName` when a state instance refers to itself
  (for example state-scoped input subscriptions), use `OtherState.STATE_NAME` when transitioning or
  registering another state, and use `SomeState.STATE_NAME` for `StateMachine` table keys.
- On entity state transitions: `exitState() -> factory() -> enterState(opts)`. Add `return` after `changeState(...)` unless follow-up is needed.

### Input

Centralized in `src/engine/input.lua`. Input is routed to the top stacked state via Herald events built from `Events.STATE_INPUT_PREFIX .. topState.stateName`.

### Events (Herald)

- `Herald.hearken(name, cb)` subscribes; `Herald.decree(name, ...)` dispatches synchronously
- Returning `false` from a handler stops propagation
- `Herald.muster()` groups subscriptions for bulk cleanup via `unhearkenAll()`
- Event names defined in `src/engine/events.lua`

### Physics and Collision

- Zero-gravity Box2D world created per `Realm`
- `Vessel` owns the collider/body abstraction; colliders are tagged (`"soul"`, `"husk"`, `"interactable"`)
- Player and AI souls use physics velocity; AI validates motion in `postPhysicsUpdate`

### Realm / Map System

`Realm` owns the current map, physics world, map-scoped entities, and the persistent player. `Realm:loadMap(mapName, destX, destY)` tears down existing objects, loads an STI map, spawns from object layers, and re-snaps the camera. Warp destinations are in `src/realm/mapTransitions.lua`.

### Entity Hierarchy

- `Soul`: base moving entity with animations, entity-local `StateMachine`, and AI helpers. Tracks `previousX/Y` for post-physics blocked-movement checks.
- `Player`: extends `Soul` with 8-directional anims and front-of-player interaction queries.
- `Husk`: lighter static/interactable prop using a `Vessel` with a static body and an overridable `interact()` method.

### Rendering Pipeline

```text
love.draw()
  GStateStack:draw()          -- all states bottom-to-top
    PlayState -> Realm:draw()
      Lens.attach / detach    -- camera-space world rendering using current View size
    Transition.draw()         -- fade overlay sized to the window
    MenuState:draw()          -- if stacked
  Debug.drawFPS()             -- debug overlay when enabled
```

Use `Util.safeDraw(fn)` to scope temporary graphics state changes.

### Camera

`Lens` owns the shared HUMP camera instance and uses `View.getScale()` for zoom. `Realm:update()` follows the player after physics/state updates, `Realm:loadMap()` uses `Lens.snapTo(...)` to avoid map-load easing, and `Realm:draw()` wraps world rendering in `Lens.attach/detach` using the current view size. Do not create other camera instances.

### Window Scaling

`main.lua` creates a resizable window with `love.window.setMode(...)`, and screen-space UI or overlays should size themselves from `View.getWidth()`, `View.getHeight()`, and `View.getScale()`.

### UI Theme

`src/graphics/theme.lua` builds `GTheme` from `GArt` and `GFonts`. Extend `GTheme` rather than hardcoding panel/font/color choices in each state.

### Third-Party Libraries

See `lib/` and `src/deps.lua`. Do not modify files under `lib/` unless asked.
