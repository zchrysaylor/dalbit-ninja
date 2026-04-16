# NPC/Enemy Movement System Breakdown

This document provides a detailed explanation of how NPC/enemy movement logic works in this LÖVE2D Zelda-style game.

## Overview

The movement system uses a **state-machine-based architecture** with simple randomized AI behavior. NPCs wander randomly around rooms, bouncing off walls, and occasionally pausing in idle states.

---

## Architecture Components

### 1. Core Classes

#### Entity (`src/Entity.lua`)
The base class for all game entities (player, enemies):
- **Position**: `x`, `y` coordinates
- **Dimensions**: `width`, `height` (typically 16x16 pixels)
- **Direction**: `'left'`, `'right'`, `'up'`, `'down'`
- **Movement Speed**: `walkSpeed` (default 20 pixels/sec for enemies, 60 for player)
- **State Machine**: Controls behavior states
- **Animations**: Sprite animations keyed by state and direction
- **Health**: Hit points and death state

#### StateMachine (`src/StateMachine.lua`)
Manages state transitions and AI processing:
- `change(stateName, enterParams)` - Switch to a new state
- `update(dt)` - Update the current state
- `render()` - Render the current state
- `processAI(params, dt)` - **Entry point for AI decision-making**

---

## Movement States

### State Diagram

```
                    ┌─────────────┐
                    │    Idle     │
                    │  (waiting)  │
                    └──────┬──────┘
                           │ wait timer expires
                           ▼
                    ┌─────────────┐
                    │    Walk     │◄─────────────────┐
                    │  (moving)   │                  │
                    └──────┬──────┘                  │
                           │                         │
         ┌─────────────────┼─────────────────┐       │
         │                 │                 │       │
    33%  │          67%    │          wall   │       │
         ▼                 ▼            bump  │       │
    ┌─────────┐    ┌─────────────┐           │       │
    │  Idle   │    │    Walk     │───────────┘       │
    │ (pause) │    │(new random  │   pick new dir   │
    └─────────┘    │ direction)  │◄──────────────────┘
                   └─────────────┘   move timer expires
```

### EntityIdleState (`src/states/entity/EntityIdleState.lua`)

**Purpose**: NPC stands still, waiting before next movement

**Logic**:
```lua
function EntityIdleState:processAI(params, dt)
    if self.waitDuration == 0 then
        -- First time entering: pick random wait time (1-5 seconds)
        self.waitDuration = math.random(5)
    else
        -- Accumulate time
        self.waitTimer = self.waitTimer + dt
        
        -- When timer expires, transition to walking
        if self.waitTimer > self.waitDuration then
            self.entity:changeState('walk')
        end
    end
end
```

**Key Points**:
- Wait duration is randomized between 1-5 seconds each time
- Uses `processAI()` method called by the update loop
- Immediately changes to `walk` state when timer expires

### EntityWalkState (`src/states/entity/EntityWalkState.lua`)

**Purpose**: NPC moves in a direction, handles wall collision and AI decisions

**AI Logic (`processAI` method)**:
```lua
function EntityWalkState:processAI(params, dt)
    local directions = {'left', 'right', 'up', 'down'}
    
    -- Condition 1: Just started walking OR hit a wall
    if self.moveDuration == 0 or self.bumped then
        -- Pick random movement duration (1-5 seconds)
        self.moveDuration = math.random(5)
        -- Pick random direction
        self.entity.direction = directions[math.random(#directions)]
        -- Change animation to match new direction
        self.entity:changeAnimation('walk-' .. self.entity.direction)
        
    -- Condition 2: Movement timer expired
    elseif self.movementTimer > self.moveDuration then
        self.movementTimer = 0
        
        -- 33% chance to go idle, 67% chance to keep walking
        if math.random(3) == 1 then
            self.entity:changeState('idle')
        else
            -- Pick new random direction and continue
            self.moveDuration = math.random(5)
            self.entity.direction = directions[math.random(#directions)]
            self.entity:changeAnimation('walk-' .. self.entity.direction)
        end
    end
    
    -- Accumulate movement time
    self.movementTimer = self.movementTimer + dt
end
```

**Movement Execution (`update` method)**:
```lua
function EntityWalkState:update(dt)
    self.bumped = false  -- Reset collision flag each frame
    
    if self.entity.direction == 'left' then
        -- Move left by walkSpeed * deltaTime
        self.entity.x = self.entity.x - self.entity.walkSpeed * dt
        
        -- Wall collision: left boundary
        if self.entity.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then 
            -- Snap to wall and mark as bumped
            self.entity.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.bumped = true
        end
        
    elseif self.entity.direction == 'right' then
        self.entity.x = self.entity.x + self.entity.walkSpeed * dt
        
        -- Wall collision: right boundary
        if self.entity.x + self.entity.width >= VIRTUAL_WIDTH - TILE_SIZE then
            self.entity.x = VIRTUAL_WIDTH - TILE_SIZE - self.entity.width
            self.bumped = true
        end
        
    elseif self.entity.direction == 'up' then
        self.entity.y = self.entity.y - self.entity.walkSpeed * dt
        
        -- Wall collision: top boundary
        if self.entity.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2 then 
            self.entity.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2
            self.bumped = true
        end
        
    elseif self.entity.direction == 'down' then
        self.entity.y = self.entity.y + self.entity.walkSpeed * dt
        
        -- Wall collision: bottom boundary
        if self.entity.y + self.entity.height >= VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE then
            
            self.entity.y = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
                + MAP_RENDER_OFFSET_Y - TILE_SIZE - self.entity.height
            self.bumped = true
        end
    end
end
```

**Key Points**:
- Movement is frame-rate independent (uses `dt` - delta time)
- Wall collision snaps entity to boundary and sets `bumped = true`
- The `bumped` flag triggers immediate direction change in the next `processAI()` call
- Movement continues for random 1-5 second intervals
- 33% chance to pause (idle) after each movement interval
- When continuing to walk, a new random direction is always picked

---

## Entity Creation and State Assignment

### Room:generateEntities (`src/world/Room.lua`)

Entities are spawned with their state machines configured:

```lua
function Room:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}
    
    -- Spawn 10 random enemies
    for i = 1, 10 do
        local type = types[math.random(#types)]
        
        -- Create entity with animations and properties
        table.insert(self.entities, Entity {
            animations = ENTITY_DEFS[type].animations,
            walkSpeed = ENTITY_DEFS[type].walkSpeed or 20,  -- Default 20 px/sec
            x = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                            VIRTUAL_WIDTH - TILE_SIZE - 16),
            y = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                            VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
                                + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16),
            width = 16,
            height = 16,
            health = 1
        })
        
        -- Assign state machine with AI states
        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[i]) end,
            ['idle'] = function() return EntityIdleState(self.entities[i]) end
        }
        
        -- Start in walk state
        self.entities[i]:changeState('walk')
    end
end
```

**Key Points**:
- 5 enemy types share the same movement behavior (skeleton, slime, bat, ghost, spider)
- All entities get a `walk` and `idle` state
- Entities start in the `walk` state immediately
- Spawn position is random within room boundaries

---

## Update Loop Flow

### Room:update (`src/world/Room.lua`)

The main update loop triggers AI and movement:

```lua
function Room:update(dt)
    -- Skip updates during room transitions
    if self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0 then return end
    
    -- Update player (handles input)
    self.player:update(dt)
    
    -- Update all entities
    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]
        
        -- Remove dead entities
        if entity.health <= 0 then
            entity.dead = true
        elseif not entity.dead then
            -- IMPORTANT: AI decision-making happens here
            entity:processAI({room = self}, dt)
            
            -- Execute state update (handles actual movement)
            entity:update(dt)
        end
        
        -- Check player-enemy collision for damage
        if not entity.dead and self.player:collides(entity) 
           and not self.player.invulnerable then
            gSounds['hit-player']:play()
            self.player:damage(1)
            self.player:goInvulnerable(1.5)
        end
    end
end
```

**Critical Sequence**:
1. `entity:processAI({room = self}, dt)` - AI makes decisions (state changes)
2. `entity:update(dt)` - Current state executes (movement, collision)

---

## Collision Detection

### Entity AABB Collision (`src/Entity.lua`)

Basic bounding box collision for entity-entity interactions:

```lua
function Entity:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                self.y + self.height < target.y or self.y > target.y + target.height)
end
```

### Wall Collision

Handled in `EntityWalkState:update()` with hardcoded map boundaries:
- Left boundary: `MAP_RENDER_OFFSET_X + TILE_SIZE`
- Right boundary: `VIRTUAL_WIDTH - TILE_SIZE - entity.width`
- Top boundary: `MAP_RENDER_OFFSET_Y + TILE_SIZE - entity.height / 2`
- Bottom boundary: Complex calculation based on map dimensions

---

## Movement Parameters

### Speeds (from `src/constants.lua` and `Room.lua`)

| Entity Type | Speed | Location |
|-------------|-------|----------|
| Player | 60 pixels/sec | `constants.lua` |
| Enemies | 20 pixels/sec | `Room:generateEntities()` (default) |

### Timing Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Wait Duration | 1-5 seconds (random) | Time spent in idle state |
| Move Duration | 1-5 seconds (random) | Time spent walking in one direction |
| Idle Chance | 33% (1 in 3) | Probability of pausing after movement |
| Direction Pool | 4 directions | left, right, up, down (equal probability) |

---

## AI Behavior Summary

### What the AI Does:

1. **Random Wandering** - Picks random directions with no pathfinding
2. **Timed Intervals** - Walks for 1-5 seconds before re-evaluating
3. **Wall Bouncing** - Hits wall → immediately picks new random direction
4. **Occasional Pauses** - 33% chance to idle between movements
5. **No Player Tracking** - Does not chase or avoid the player
6. **No Entity Collision** - Enemies can overlap with each other

### What the AI Does NOT Do:

- ❌ Pathfinding to player
- ❌ Avoiding obstacles (other than walls)
- ❌ Coordinating with other enemies
- ❌ Reacting to player attacks
- ❌ Varying speed based on context
- ❌ Any sophisticated decision-making

---

## Key Files Reference

| File | Role in Movement System |
|------|-------------------------|
| `src/Entity.lua` | Base entity class, position, collision |
| `src/StateMachine.lua` | State management and AI routing |
| `src/states/entity/EntityIdleState.lua` | Idle behavior, wait timing |
| `src/states/entity/EntityWalkState.lua` | Movement, AI, collision detection |
| `src/world/Room.lua` | Entity spawning, main update loop |
| `src/entity_defs.lua` | Animation definitions per entity type |
| `src/constants.lua` | Speed and dimension constants |

---

## Example Movement Sequence

Here's a typical movement sequence for an enemy:

```
Frame 1: Spawn in 'walk' state
  → processAI(): moveDuration=0, so set moveDuration=3, direction='right'
  → update(): Move right, no wall collision

Frame 2-60: Walking right for 3 seconds
  → processAI(): movementTimer accumulates
  → update(): Continue moving right

Frame 61: Hit right wall
  → processAI(): bumped=true, so pick new moveDuration=2, direction='up'
  → update(): Move up (away from wall)

Frame 62-120: Walking up for 2 seconds
  → processAI(): movementTimer accumulates
  → update(): Continue moving up

Frame 121: Movement timer expires
  → processAI(): roll die (1-3), result=2 → continue walking
  → Set moveDuration=4, direction='left'
  → update(): Move left

... continues indefinitely
```

---

## Extending the System

To add new movement behaviors, you would:

1. **Create new state files** in `src/states/entity/` (e.g., `EntityChaseState.lua`)
2. **Add states to the StateMachine** in `Room:generateEntities()`:
   ```lua
   self.entities[i].stateMachine = StateMachine {
       ['walk'] = function() return EntityWalkState(self.entities[i]) end,
       ['idle'] = function() return EntityIdleState(self.entities[i]) end,
       ['chase'] = function() return EntityChaseState(self.entities[i]) end
   }
   ```
3. **Implement `processAI` and `update`** in the new state
4. **Transition between states** using `entity:changeState('newState')`

---

## Summary

The NPC movement system is a **simple, randomized state machine** perfect for a classic Zelda-style game. It provides:

- ✅ Unpredictable, organic movement patterns
- ✅ Wall boundary respect
- ✅ Easy to understand and extend
- ✅ Frame-rate independent movement
- ❌ No sophisticated AI or pathfinding

This system prioritizes simplicity and performance over complex AI behaviors, which fits the retro aesthetic and gameplay style of the game.
