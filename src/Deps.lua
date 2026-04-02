-- animation library
-- https://github.com/kikito/anim8
Anim8 = require("lib.anim8")

-- camera library
-- https://github.com/vrld/hump
HumpCamera = require("lib.camera")

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
require("src.world.Level")
require("src.world.LevelMap")

Collision = require("src.Collision")
Entity = require("src.entity.Entity")
Player = require("src.entity.Player")
StateMachine = require("src.state.StateMachine")
StartState = require("src.state.StartState")
PlayState = require("src.state.PlayState")

GFonts = {
	["sproutlandsSmall"] = love.graphics.newFont("fonts/sproutlands.ttf", 12),
	["sproutlandsMedium"] = love.graphics.newFont("fonts/sproutlands.ttf", 20),
	["sproutlandsLarge"] = love.graphics.newFont("fonts/sproutlands.ttf", 36),
}

GArt = { ["sprite-player"] = love.graphics.newImage("art/gb-sprite.png") }
