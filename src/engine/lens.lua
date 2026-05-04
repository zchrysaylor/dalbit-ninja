---Camera control module. Owns the HUMP camera instance and exposes
---attach/detach for viewport clipping and follow logic for player tracking.
---@class lens
local lens = {}

-- NOTE: as camera stiffness decreases, settle screen pixels should increase
local CAMERA_STIFFNESS = 8
local CAMERA_SETTLE_SCREEN_PIXELS = 1.5
local CAMERA_STOPPED_SPEED = 0.01

local cam = HumpCamera()
cam.smoother = HumpCamera.smooth.damped(CAMERA_STIFFNESS)

local function snapToScreenPixel(value, scale)
	return math.floor(value * scale + 0.5) / scale
end

local function isPlayerStopped(player)
	if not player.vessel then
		return false
	end

	local vx, vy = player.vessel:getLinearVelocity()
	return vx * vx + vy * vy <= CAMERA_STOPPED_SPEED * CAMERA_STOPPED_SPEED
end

---Compute the clamped target camera center for the current map bounds.
---@param player Soul Entity with x and y fields representing its center position
---@param map table STI map instance with width, height, tilewidth, and tileheight fields
---@return number targetX
---@return number targetY
local function getFollowTarget(player, map)
	local mapWidth = map.width * map.tilewidth
	local mapHeight = map.height * map.tileheight
	local halfViewW = love.graphics.getWidth() / (2 * cam.scale)
	local halfViewH = love.graphics.getHeight() / (2 * cam.scale)
	local minX = halfViewW
	local maxX = mapWidth - halfViewW
	local minY = halfViewH
	local maxY = mapHeight - halfViewH
	local targetX = player.x
	local targetY = player.y

	if minX > maxX then
		targetX = mapWidth / 2
	else
		targetX = math.max(minX, math.min(maxX, targetX))
	end

	if minY > maxY then
		targetY = mapHeight / 2
	else
		targetY = math.max(minY, math.min(maxY, targetY))
	end

	return targetX, targetY
end

---Begin rendering through the camera viewport. All draw calls made between
---attach and detach will be transformed by the camera.
---@param x number Viewport top-left X in screen coordinates
---@param y number Viewport top-left Y in screen coordinates
---@param w number Viewport width in pixels
---@param h number Viewport height in pixels
---@param noclip? boolean If true, disables scissor clipping (default false)
---@return nil
function lens.attach(x, y, w, h, noclip)
	local camX, camY = cam.x, cam.y
	local scale = cam.scale
	cam.x = snapToScreenPixel(cam.x, scale)
	cam.y = snapToScreenPixel(cam.y, scale)
	cam:attach(x, y, w, h, noclip)
	cam.x, cam.y = camX, camY
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
	local targetX, targetY = getFollowTarget(player, map)
	local dx = targetX - cam.x
	local dy = targetY - cam.y
	local settleDistance = CAMERA_SETTLE_SCREEN_PIXELS / cam.scale

	if isPlayerStopped(player) and dx * dx + dy * dy <= settleDistance * settleDistance then
		return
	end

	cam:lockPosition(targetX, targetY)
end

---Snap the camera immediately to the clamped target position.
---@param player Soul Entity with x and y fields representing its center position
---@param map table STI map instance with width, height, tilewidth, and tileheight fields
---@return nil
function lens.snapTo(player, map)
	local targetX, targetY = getFollowTarget(player, map)
	cam:lookAt(targetX, targetY)
end

---Set the camera zoom level. Values greater than 1 zoom in; less than 1 zoom out.
---Zoom is accounted for in lens.follow's map boundary clamping.
---@param zoom number Zoom scale factor (e.g. 1 = default, 2 = 2x zoom in)
---@return nil
function lens.setZoom(zoom)
	cam.scale = zoom
end

return lens
