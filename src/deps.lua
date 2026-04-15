--- Centralized dependency loader. Required once from main.lua.
--- Loads all third-party libraries, game modules, and assets into globals so
--- consuming files never need to require them individually.

-- animation library
-- https://github.com/kikito/anim8
Anim8 = require("lib.anim8")

-- camera library
-- https://github.com/vrld/hump
-- required in lens.lua only

-- tween library
-- https://github.com/rxi/flux
Flux = require("lib.flux.flux")

-- resolution handling library
-- https://github.com/Ulydev/push
Push = require("lib.push")

-- Simple Tiled Implementation map library
-- https://github.com/karai17/Simple-Tiled-Implementation
Tiled = require("lib.sti")

require("src.constants")
Util = require("src.util")

-- engine-related requires
Collision = require("src.engine.collision")
Events = require("src.engine.events")
Input = require("src.engine.input")
Lens = require("src.engine.lens")
Physics = require("src.engine.physics")
Signal = require("src.engine.signal")
Debug = require("src.engine.dbg") -- depends on Signal & Events; must be loaded after
Transition = require("src.engine.transition") -- depends on Signal & Events; must be loaded after

-- vessel-related requires
Vessel = require("src.vessel.Vessel")
Soul = require("src.vessel.soul.Soul")
Husk = require("src.vessel.husk.Husk")
Player = require("src.vessel.soul.Player")

-- realm-related requires
Realm = require("src.realm.Realm")
WallSpawner = require("src.realm.WallSpawner")
WarpSpawner = require("src.realm.WarpSpawner")
SoulSpawner = require("src.realm.SoulSpawner")
HuskSpawner = require("src.realm.HuskSpawner")

-- state machine-related requires
StateMachine = require("src.state.StateMachine")
StartState = require("src.state.game.StartState")
PlayState = require("src.state.game.PlayState")
SoulIdleState = require("src.state.vessel.soul.SoulIdleState")
SoulWalkState = require("src.state.vessel.soul.SoulWalkState")
HuskIdleState = require("src.state.vessel.husk.HuskIdleState")
PlayerIdleState = require("src.state.vessel.soul.player.PlayerIdleState")
PlayerWalkState = require("src.state.vessel.soul.player.PlayerWalkState")

---@type table<string, love.Font> Global font table.
GFonts = {
	-- TODO: add dedicated pixel font for in-game menu
	["antiquity"] = love.graphics.newFont("fonts/antiquity-print.ttf", 12),
	["debug"] = love.graphics.newFont("fonts/sproutlands.ttf", 24),
	["sproutlandsSmall"] = love.graphics.newFont("fonts/sproutlands.ttf", 12),
	["sproutlandsMedium"] = love.graphics.newFont("fonts/sproutlands.ttf", 20),
	["sproutlandsLarge"] = love.graphics.newFont("fonts/sproutlands.ttf", 36),
}

---@type table<string, love.Image> Global image table.
GArt = {
	["sprite-player"] = love.graphics.newImage("art/sprite-player.png"),
	["sprite-enemy-fire"] = love.graphics.newImage("art/sprite-enemy-fire.png"),
	["chest"] = love.graphics.newImage("art/chest.png"),
}
