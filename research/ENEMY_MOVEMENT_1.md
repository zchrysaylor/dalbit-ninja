# Enemy Movement System Breakdown

## Overview

The enemy movement system in `src/enemies/enemy.lua` uses a **state machine-based architecture** with physics integration. It supports multiple movement modes including wandering, chasing, and special states (stun, dizzy, hooked).

---

## State Machine System

Enemies use numeric state constants defined at the top of the file:

| State | Value | Description |
|-------|-------|-------------|
| `idle` | 0 | Standing still (rarely used) |
| `wander_stopped` | 1 | Pausing between wander movements |
| `wander_moving` | 1.1 | Currently wandering around spawn point |
| `alert` | 99 | Player detected, preparing to attack |
| `attacking` | 100 | Aggressively pursuing or attacking player |

```lua
-- Enemy states:
-- 0: idle, standing
-- 1: wander, stopped
-- 1.1: wander, moving
-- 99: alert
-- 100: attacking
enemy.state = 1
```

---

## Core Movement Flow

### 1. Initialization (`spawnEnemy()`)

Each enemy is spawned with:
- **Start position** (`startX`, `startY`) - anchor point for wandering
- **Wander radius** (`wanderRadius = 30`) - max distance from spawn
- **Wander speed** (`wanderSpeed = 15`) - movement speed while idle
- **Chase flag** (`chase = true`) - whether to pursue player when detected

### 2. Main Update Chain

Every frame, enemies go through this update sequence:

```
enemy:update(dt)      → Type-specific update (eye, bat, skeleton)
enemy:genericUpdate(dt) → Shared state management, timers, effects
  └── enemy:moveLogic(dt, stiff) → Core movement calculations
  └── enemy:wanderUpdate(dt) → Idle behavior when not alert
```

---

## Player Detection (`lookForPlayer()`)

The enemy detects the player through a sophisticated line-of-sight system:

### Detection Methods (in order of priority)

1. **Proximity Check** (30px range)
   ```lua
   if distanceBetween(ex, ey, player:getX(), player:getY()) < 30 then
       return true
   end
   ```
   - Always triggers if player is very close (stealth/backstab)

2. **Directional Facing Check** (wander states only)
   ```lua
   if self.scaleX == 1 and ex > player:getX() then return false end
   if self.scaleX == -1 and ex < player:getX() then return false end
   ```
   - Enemies only look in the direction they're facing during wander
   - Prevents 360-degree vision during idle patrol

3. **Line-of-Sight Raycast** (18 query points)
   ```lua
   for i=1,18 do
       local qRad = 3
       local qx = ex + toPlayerVec.x * i * qRad
       local qy = ey + toPlayerVec.y * i * qRad
       
       local hitPlayer = world:queryCircleArea(qx, qy, qRad, {'Player'})
       local obstacles = world:queryCircleArea(qx, qy, qRad, {'Wall'})
   end
   ```
   - Casts 18 circular queries along a vector toward player
   - Radius per query: 3 pixels
   - Total range: ~54 pixels (18 × 3)
   - **Blocked by walls**: If any query hits a Wall, detection fails
   - **Player hit**: Returns true if player collider intersects any query point

---

## Movement Modes

### Mode 1: Wander Behavior (`wanderUpdate()`)

Used when `state < 2` (not alert/attacking).

**Timer-Based State Transitions:**
```
wanderTimer (random 0.5-2.5s) → state 1.1 (moving)
wanderBufferTimer (0.2s) → prevents immediate direction changes
```

**Direction Selection Logic:**
The enemy calculates which "quadrant" it's in relative to spawn, then chooses a direction toward center:

```lua
if ex < startX and ey < startY then     -- Top-left quadrant
    wanderDir = vector(0, 1)            -- Move down
elseif ex > startX and ey < startY then  -- Top-right quadrant  
    wanderDir = vector(-1, 0)           -- Move left
elseif ex < startX and ey > startY then  -- Bottom-left quadrant
    wanderDir = vector(1, 0)            -- Move right
else                                     -- Bottom-right quadrant
    wanderDir = vector(0, -1)           -- Move up
end

-- Add random rotation (-90° to +90° from center direction)
wanderDir:rotateInplace(math.pi/-2 * math.random())
```

**Movement Execution:**
```lua
self.physics:setX(self.physics:getX() + wanderDir.x * wanderSpeed * dt)
self.physics:setY(self.physics:getY() + wanderDir.y * wanderSpeed * dt)
```
- Uses direct position manipulation (not forces)
- Movement stops if outside `wanderRadius` from spawn

---

### Mode 2: Attack/Chase (`moveLogic()`)

Triggered when `state >= 100`.

**State Flow:**
```
wander (1/1.1) → lookForPlayer() → alert (99) → animTimer countdown → attack (100)
```

**Chase Movement (Two Styles):**

1. **Stiff/Grounded Movement** (`stiff = true`)
   ```lua
   self.physics:setX(self.physics:getX() + dir.x * dt)
   self.physics:setY(self.physics:getY() + dir.y * dt)
   ```
   - Direct position updates
   - Used by: `skeleton`

2. **Floaty/Air Movement** (`stiff = false`)
   ```lua
   if distanceBetween(0, 0, self.physics:getLinearVelocity()) < self.maxSpeed then
       self.physics:applyForce(dir:unpack())
   end
   ```
   - Uses physics forces with max speed clamp
   - Used by: `bat`, `eye`

**Direction Calculation:**
```lua
self.dir = vector(px - ex, py - ey):normalized() * self.magnitude
```
- Vector from enemy to player, normalized, scaled by enemy's `magnitude`
- `magnitude` varies by enemy type (different chase speeds)

---

## Special States & Effects

### Stun State (`stunTimer`)
```lua
if self.stunTimer > 0 then
    self.stunTimer = self.stunTimer - dt
    -- Animation pauses (anim:update not called)
    -- Movement blocked (state checks)
end
```
- Triggered by: Player attacks
- Effect: Enemy frozen, physics impulse applied

### Dizzy State (`dizzyTimer`)
```lua
if self.dizzyTimer > 0 then
    -- Wander blocked: if self.state < 1 or self.state >= 2 or self.dizzyTimer > 0 then return end
end
```
- Prevents wandering behavior
- Enemy still alert/attacking but movement erratic

### Hooked State (`hookVec`)
```lua
if self.hookVec and self.dizzyTimer > 0 and grapple.state == -1 then
    self.physics:setLinearVelocity(0, 0)
    self.physics:setX( self.physics:getX() + (self.hookVec.x * grapple.speed * -1 * dt) )
    self.physics:setY( self.physics:getY() + (self.hookVec.y * grapple.speed * -1 * dt) )
end
```
- Triggered when grapple hook attaches
- Enemy pulled toward player at `grapple.speed`
- Velocity zeroed to ensure clean pull

---

## Visual Feedback (`setScaleX()`)

Enemies face different directions based on state:

**During Alert/Attack (state >= 99):**
```lua
if px < ex then
    self.scaleX = -1  -- Face left
else
    self.scaleX = 1   -- Face right
end
```
- Always faces player during combat

**During Wander (state 1-2):**
```lua
if self.wanderDir.x < 0 then
    self.scaleX = -1  -- Face left
else
    self.scaleX = 1   -- Face right
end
```
- Faces movement direction while patrolling

---

## Enemy Type Customization

Different enemy types load from separate files and customize movement:

```lua
if type == "eye" then
    init = require("src/enemies/eye")
elseif type == "bat" then
    init = require("src/enemies/bat")
elseif type == "skeleton" then
    init = require("src/enemies/skeleton")
end
enemy = init(enemy, x, y, args)
```

Each type typically sets:
- `enemy.magnitude` - Chase speed multiplier
- `enemy.maxSpeed` - Physics velocity cap (floaty enemies)
- Custom `enemy:update(dt)` - Type-specific logic

---

## Timer-Based State Transitions

**Alert → Attack Transition:**
```lua
if self.animTimer > 0 then
    self.animTimer = self.animTimer - dt
    if self.animTimer < 0 then
        if self.state == 99 then self.state = 100 end
        self.animTimer = 0
    end
end
```
- `animTimer = 0.5` when player first detected
- Brief "surprise" pause before attacking

**Generic Timer Pattern:**
```lua
if timer > 0 then
    timer = timer - dt
    if timer < 0 then timer = 0 end  -- Clamp to prevent negatives
end
```
- Used for: flashTimer, burningTimer, emberTimer, stunTimer, dizzyTimer

---

## Key Design Patterns

1. **Backward Iteration for Cleanup**
   ```lua
   for i=#enemies,1,-1 do
       if enemies[i].dead then
           enemies[i].physics:destroy()
           table.remove(enemies, i)
       end
   end
   ```

2. **Conditional Physics Manipulation**
   - Direct `setX/setY` for precise control (wander, stiff enemies)
   - `applyForce` for momentum-based movement (bats, floating)

3. **State-Guarded Logic**
   - All movement functions check `state` ranges before executing
   - Prevents wander/attack logic from interfering

4. **Modular Enemy Types**
   - Base enemy.lua provides shared state machine
   - Type-specific files (eye.lua, bat.lua, skeleton.lua) customize physics and behavior

---

## Summary

The enemy movement system creates believable AI behavior through:
- **Zone-based patrolling** with wander radius enforcement
- **Directional vision** during idle, 360° vision during alert  
- **Physics-based chase** with type-specific movement styles
- **Line-of-sight detection** with wall occlusion
- **State machine transitions** for smooth behavior changes
- **Status effects** (stun, dizzy, hook) that interrupt normal flow
