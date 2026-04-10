--- Centralized dependency loader. Required once from main.lua.
--- Loads all third-party libraries, game modules, and assets into globals so
--- consuming files never need to require them individually.

-- animation library
-- https://github.com/kikito/anim8
Anim8 = require("lib.anim8")

-- camera library
-- https://github.com/vrld/hump
HumpCamera = require("lib.camera")

-- tween library
-- https://github.com/rxi/flux
Flux = require("lib.flux.flux")

-- resolution handling library
-- https://github.com/Ulydev/push
Push = require("lib.push")

-- Simple Tiled Implementation map library
-- https://github.com/karai17/Simple-Tiled-Implementation
Tiled = require("lib.sti")

-- timer management library
-- https://github.com/airstruck/knife
Timer = require("lib.timer")

require("src.constants")
Collision = require("src.engine.collision")
Input = require("src.engine.input")
Physics = require("src.engine.physics")
Signal = require("src.engine.signal")

Vessel = require("src.vessel.Vessel")
Soul = require("src.vessel.soul.Soul")
Player = require("src.vessel.soul.Player")

Realm = require("src.realm.Realm")
WallSpawner = require("src.realm.WallSpawner")
WarpSpawner = require("src.realm.WarpSpawner")
SoulSpawner = require("src.realm.SoulSpawner")

StateMachine = require("src.state.StateMachine")
StartState = require("src.state.StartState")
PlayState = require("src.state.PlayState")
SoulIdleState = require("src.state.vessel.soul.SoulIdleState")
SoulWalkState = require("src.state.vessel.soul.SoulWalkState")
PlayerIdleState = require("src.state.vessel.soul.player.PlayerIdleState")
PlayerWalkState = require("src.state.vessel.soul.player.PlayerWalkState")

---@type table<string, love.Font> Named global font table.
GFonts = {
	["sproutlandsSmall"] = love.graphics.newFont("fonts/sproutlands.ttf", 12),
	["sproutlandsMedium"] = love.graphics.newFont("fonts/sproutlands.ttf", 20),
	["sproutlandsLarge"] = love.graphics.newFont("fonts/sproutlands.ttf", 36),
	["antiquity"] = love.graphics.newFont("fonts/antiquity-print.ttf", 12),
}

---@type table<string, love.Image> Named global image table.
GArt = {
	["sprite-player"] = love.graphics.newImage("art/sprite-player.png"),
	["sprite-enemy-fire"] = love.graphics.newImage("art/sprite-enemy-fire.png"),
}
