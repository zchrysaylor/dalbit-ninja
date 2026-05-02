--- Centralized dependency loader. Required once from main.lua.
--- Loads all third-party libraries, game modules, and assets into globals so
--- consuming files never need to require them individually.

-- animation library
-- https://github.com/kikito/anim8
Anim8 = require("lib.anim8.anim8")

-- camera library
-- https://github.com/vrld/hump
-- required in lens.lua only

-- tween library
-- https://github.com/rxi/flux
Flux = require("lib.flux.flux")

-- resolution handling library
-- https://github.com/Ulydev/push
Push = require("lib.push.push")

-- Simple Tiled Implementation map library
-- https://github.com/karai17/Simple-Tiled-Implementation
Tiled = require("lib.sti.init")

require("src.constants")
Util = require("src.util")

-- engine-related requires
Collision = require("src.engine.collision")
Events = require("src.engine.events")
Input = require("src.engine.input")
Lens = require("src.engine.lens")
Physics = require("src.engine.physics")
Herald = require("src.engine.herald")
Debug = require("src.engine.dbg") -- depends on Herald & Events; must be loaded after
Transition = require("src.engine.transition") -- depends on Herald & Events; must be loaded after

-- user interface-related requires
NineSlice = require("src.graphics.nineSlice")

-- vessel-related requires
Vessel = require("src.vessel.Vessel")
Soul = require("src.vessel.soul.Soul")
Husk = require("src.vessel.husk.Husk")
Player = require("src.vessel.soul.Player")

-- realm-related requires
Realm = require("src.realm.Realm")
MapTransitions = require("src.realm.mapTransitions")
WallSpawner = require("src.realm.WallSpawner")
WarpSpawner = require("src.realm.WarpSpawner")
SoulSpawner = require("src.realm.SoulSpawner")
HuskSpawner = require("src.realm.HuskSpawner")

-- state machine-related requires
StateStack = require("src.state.StateStack")
StateMachine = require("src.state.StateMachine")
StartState = require("src.state.game.StartState")
PlayState = require("src.state.game.PlayState")
MenuState = require("src.state.game.MenuState")
SoulIdleState = require("src.state.vessel.soul.SoulIdleState")
SoulWanderState = require("src.state.vessel.soul.SoulWanderState")
SoulChaseState = require("src.state.vessel.soul.SoulChaseState")
SoulReturnState = require("src.state.vessel.soul.SoulReturnState")
PlayerIdleState = require("src.state.vessel.soul.player.PlayerIdleState")
PlayerWalkState = require("src.state.vessel.soul.player.PlayerWalkState")
PlayerHurtState = require("src.state.vessel.soul.player.PlayerHurtState")
HuskIdleState = require("src.state.vessel.husk.HuskIdleState")

---@type table<string, love.Image> Global image table.
GArt = {
	["chest-little-blue"] = love.graphics.newImage("art/husk-chest-little-blue.png"),
	["sprite-camo-red"] = love.graphics.newImage("art/sprite-camo-red.png"),
	["sprite-player"] = love.graphics.newImage("art/sprite-player.png"),
	["panel-wood"] = love.graphics.newImage("art/ninja-theme-wood-panel.png"),
	["panel-wood-interior"] = love.graphics.newImage("art/ninja-theme-wood-panel-interior.png"),
}

---@type table<string, love.Font> Global font table.
GFonts = {
	["debug"] = love.graphics.newFont("fonts/sproutlands.ttf", 24),
	["ninjaLarge"] = love.graphics.newFont("fonts/ninja-font.ttf", 36),
	["ninjaMedium"] = love.graphics.newFont("fonts/ninja-font.ttf", 16),
	["ninjaSmall"] = love.graphics.newFont("fonts/ninja-font.ttf", 8),
	["sproutlandsLarge"] = love.graphics.newFont("fonts/sproutlands.ttf", 36),
	["sproutlandsMedium"] = love.graphics.newFont("fonts/sproutlands.ttf", 20),
	["sproutlandsSmall"] = love.graphics.newFont("fonts/sproutlands.ttf", 12),
}

GTheme = require("src.graphics.theme")
