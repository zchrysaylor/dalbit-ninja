---Camera control module. Owns the HUMP camera instance and exposes
---attach/detach for viewport clipping and follow logic for player tracking.
---@class lens
local lens = {}

-- camera library
-- https://github.com/vrld/hump
local HumpCamera = require("lib.camera")
local cam = HumpCamera()

---Begin rendering through the camera viewport. All draw calls made between
---attach and detach will be transformed by the camera.
---@param x number Viewport top-left X in screen coordinates
---@param y number Viewport top-left Y in screen coordinates
---@param w number Viewport width in pixels
---@param h number Viewport height in pixels
---@param noclip? boolean If true, disables scissor clipping (default false)
---@return nil
function lens.attach(x, y, w, h, noclip)
	cam:attach(x, y, w, h, noclip)
end

---End rendering through the camera viewport.
---@return nil
function lens.detach()
	cam:detach()
end

---Center the camera on the player and clamp so the viewport never exceeds map bounds.
---Accounts for the current zoom level when computing clamp boundaries.
---Should be called every frame before drawing, including during fades.
---@param player Soul Entity with x and y fields representing its center position
---@param map table STI map instance with width, height, tilewidth, and tileheight fields
---@return nil
function lens.follow(player, map)
	local mapWidth = map.width * map.tilewidth
	local mapHeight = map.height * map.tileheight

	cam:lookAt(player.x, player.y)

	local halfViewW = VIRTUAL_WIDTH / (2 * cam.scale)
	local halfViewH = VIRTUAL_HEIGHT / (2 * cam.scale)

	if cam.x < halfViewW then
		cam.x = halfViewW
	end
	if cam.y < halfViewH then
		cam.y = halfViewH
	end
	if cam.x > mapWidth - halfViewW then
		cam.x = mapWidth - halfViewW
	end
	if cam.y > mapHeight - halfViewH then
		cam.y = mapHeight - halfViewH
	end
end

---Set the camera zoom level. Values greater than 1 zoom in; less than 1 zoom out.
---Zoom is accounted for in lens.follow's map boundary clamping.
---@param zoom number Zoom scale factor (e.g. 1 = default, 2 = 2x zoom in)
---@return nil
function lens.setZoom(zoom)
	cam.scale = zoom
end

return lens
