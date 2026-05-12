# Graph Report - .  (2026-05-12)

## Corpus Check
- Corpus is ~40,534 words - fits in a single context window. You may not need a graph.

## Summary
- 418 nodes · 549 edges · 25 communities (24 shown, 1 thin omitted)
- Extraction: 74% EXTRACTED · 26% INFERRED · 0% AMBIGUOUS · INFERRED: 141 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Art and Theme Assets|Art and Theme Assets]]
- [[_COMMUNITY_STI Map Library|STI Map Library]]
- [[_COMMUNITY_Entity State Behavior|Entity State Behavior]]
- [[_COMMUNITY_Debug UI Transitions|Debug UI Transitions]]
- [[_COMMUNITY_Anim8 Animation Library|Anim8 Animation Library]]
- [[_COMMUNITY_Camera Library|Camera Library]]
- [[_COMMUNITY_Player Collision Interactions|Player Collision Interactions]]
- [[_COMMUNITY_App State Stack|App State Stack]]
- [[_COMMUNITY_Realm Spawners Warps|Realm Spawners Warps]]
- [[_COMMUNITY_Herald Input Events|Herald Input Events]]
- [[_COMMUNITY_Lens Camera Scaling|Lens Camera Scaling]]
- [[_COMMUNITY_Flux Tween Library|Flux Tween Library]]
- [[_COMMUNITY_Husk Archetypes Vessel|Husk Archetypes Vessel]]

## God Nodes (most connected - your core abstractions)
1. `UI Theme and NineSlice` - 19 edges
2. `Dalbit Ninja` - 14 edges
3. `BaseState.new()` - 13 edges
4. `Realm Map Spawners` - 12 edges
5. `util.safeDraw()` - 10 edges
6. `view.getHeight()` - 8 edges
7. `Vessel Composition` - 8 edges
8. `view.getWidth()` - 7 edges
9. `util.distanceSquared()` - 6 edges
10. `Soul:createStateMachine()` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Sprite Player (64x136)` --conceptually_related_to--> `Vessel Composition`  [INFERRED]
  art/sprite-player.png → README.md
- `Husk Chest Little Blue (32x16)` --conceptually_related_to--> `Vessel Composition`  [INFERRED]
  art/husk-chest-little-blue.png → README.md
- `Sprite Player Old (64x128)` --conceptually_related_to--> `Vessel Composition`  [INFERRED]
  art/sprite-player-old.png → README.md
- `Ninja Camp (368x144)` --conceptually_related_to--> `Realm Map Spawners`  [INFERRED]
  art/ninja-camp.png → AGENTS.md
- `Ninja Floor Detail (256x80)` --conceptually_related_to--> `Realm Map Spawners`  [INFERRED]
  art/ninja-floor-detail.png → AGENTS.md

## Hyperedges (group relationships)
- **Runtime Flow Architecture** — concept_state_stack, concept_state_scoped_input, concept_herald_events, concept_realm_map_spawners [EXTRACTED 0.90]
- **Presentation Layer Architecture** — concept_view_lens_camera, concept_window_space_overlays, concept_ui_theme_nineslice [EXTRACTED 0.88]
- **Entity Runtime Model** — concept_vessel_composition, concept_box2d_physics, concept_entity_state_machine [EXTRACTED 0.91]
- **Wood Theme Asset Family** — asset_ninja_theme_wood_button_disabled, asset_ninja_theme_wood_slider_disabled, asset_ninja_theme_wood_button_pressed, asset_ninja_theme_wood_panel_interior, asset_ninja_theme_wood_button, asset_ninja_theme_wood_arrow_right_hover, asset_ninja_theme_wood_arrow_right, asset_ninja_theme_wood_arrow_left_hover, asset_ninja_theme_wood_arrow_left, asset_ninja_theme_wood_panel [EXTRACTED 0.95]
- **Ninja Environment Tilesets** — asset_ninja_camp, asset_ninja_floor_detail, asset_ninja_field, asset_ninja_house, asset_ninja_nature, asset_ninja_water, asset_ninja_elements, asset_ninja_bed, asset_ninja_floor [EXTRACTED 0.92]
- **Entity Sprite Assets** — asset_sprite_camo_red, asset_sprite_player, asset_husk_chest_little_blue, asset_sprite_player_old [EXTRACTED 0.90]

## Communities (25 total, 1 thin omitted)

### Community 0 - "Art and Theme Assets"
Cohesion: 0.05
Nodes (39): Husk Chest Little Blue (32x16), Ninja Bed (224x192), Ninja Camp (368x144), Ninja Elements (256x240), Ninja Field (80x240), Ninja Floor (352x417), Ninja Floor Detail (256x80), Ninja Font (1081x8) (+31 more)

### Community 1 - "STI Map Library"
Cohesion: 0.05
Nodes (21): STI MIT/X11 License, addObjectToWorld(), calculateObjectPosition(), getPolygonVertices(), Map:getLayerTilePosition(), Map:init(), Map:setLayer(), Map:setObjectCoordinates() (+13 more)

### Community 2 - "Entity State Behavior"
Cohesion: 0.05
Nodes (13): Husk:createStateMachine(), HuskIdleState.new(), PlayerHurtState.new(), PlayerIdleState.new(), PlayerWalkState.new(), Player:createStateMachine(), Soul:createStateMachine(), SoulChaseState.new() (+5 more)

### Community 3 - "Debug UI Transitions"
Cohesion: 0.11
Nodes (21): collision.drawColliders(), collision.drawQueries(), dbg.drawAll(), dbg.drawFPS(), dbg.drawMenu(), physics.new(), transition.draw(), transition.fade() (+13 more)

### Community 4 - "Anim8 Animation Library"
Cohesion: 0.11
Nodes (15): Animation:clone(), Animation:update(), assertPositiveInteger(), cloneArray(), createFrame(), getGridKey(), getOrCreateFrame(), Grid:getFrames() (+7 more)

### Community 8 - "Player Collision Interactions"
Cohesion: 0.14
Nodes (14): circleIntersectsPolygon(), collision.queryCircleArea(), distanceSquaredToSegment(), fixtureIntersectsCircle(), pointInCircle(), pointInPolygon(), Player:checkDamage(), Player:draw() (+6 more)

### Community 9 - "App State Stack"
Cohesion: 0.12
Nodes (6): State Stack Screen Flow, love.load(), love.resize(), lens.setZoom(), view.getScale(), StateStack.new()

### Community 10 - "Realm Spawners Warps"
Cohesion: 0.14
Nodes (13): collision.isColliding(), HuskSpawner.destroyAll(), HuskSpawner.spawn(), Realm:checkWarps(), Realm:destroyAll(), Realm:loadMap(), SoulSpawner.destroyAll(), SoulSpawner.spawn() (+5 more)

### Community 11 - "Herald Input Events"
Cohesion: 0.15
Nodes (10): Herald Event Bus, State-Scoped Input Routing, herald.compact(), herald.decree(), herald.hearken(), herald.muster(), input.getDirection(), input:keyPressed() (+2 more)

### Community 12 - "Lens Camera Scaling"
Cohesion: 0.19
Nodes (14): View and Lens Camera Scaling, Window-Space Overlays, clampToMap(), getFollowTarget(), isPlayerStopped(), lens.attach(), lens.detach(), lens.follow() (+6 more)

### Community 14 - "Flux Tween Library"
Cohesion: 0.18
Nodes (3): flux:to(), tween:after(), tween.new()

### Community 15 - "Husk Archetypes Vessel"
Cohesion: 0.17
Nodes (4): ArchetypeCamoRed.spawn(), Husk.new(), Soul.new(), Vessel.new()

## Knowledge Gaps
- **6 isolated node(s):** `LÖVE GBA-Style Game`, `LuaLS Documentation`, `Lua Syntax Checks`, `anim8 MIT License`, `STI MIT/X11 License` (+1 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Dalbit Ninja` connect `Art and Theme Assets` to `App State Stack`, `Herald Input Events`, `Lens Camera Scaling`?**
  _High betweenness centrality (0.100) - this node is a cross-community bridge._
- **Why does `BaseState.new()` connect `Entity State Behavior` to `Debug UI Transitions`?**
  _High betweenness centrality (0.096) - this node is a cross-community bridge._
- **Why does `Vessel Composition` connect `Art and Theme Assets` to `Soul AI Core`, `Husk Archetypes Vessel`?**
  _High betweenness centrality (0.084) - this node is a cross-community bridge._
- **Are the 16 inferred relationships involving `UI Theme and NineSlice` (e.g. with `Window-Space Overlays` and `Global Dependency Loader`) actually correct?**
  _`UI Theme and NineSlice` has 16 INFERRED edges - model-reasoned connections that need verification._
- **Are the 12 inferred relationships involving `BaseState.new()` (e.g. with `StateMachine.new()` and `StartState.new()`) actually correct?**
  _`BaseState.new()` has 12 INFERRED edges - model-reasoned connections that need verification._
- **Are the 10 inferred relationships involving `Realm Map Spawners` (e.g. with `Box2D Physics Vessels` and `Ninja Camp (368x144)`) actually correct?**
  _`Realm Map Spawners` has 10 INFERRED edges - model-reasoned connections that need verification._
- **What connects `LÖVE GBA-Style Game`, `LuaLS Documentation`, `Lua Syntax Checks` to the rest of the system?**
  _6 weakly-connected nodes found - possible documentation gaps or missing edges._