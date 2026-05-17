---Camera control module.
---@class lens
local lens = {}

-- NOTE: as camera stiffness decreases, settle screen pixels should increase
local CAMERA_STIFFNESS = 8
local CAMERA_SETTLE_SCREEN_PIXELS = 1.5
local CAMERA_STOPPED_SPEED = 0.01

local SHAKE_DURATION = 0.1
local SHAKE_INTENSITY = 2
local SHAKE_SPEED = 0.03
local SHAKE_FADE_SPEED = 15

local cam = HumpCamera()
cam.smoother = HumpCamera.smooth.damped(CAMERA_STIFFNESS)

local shake = {
    time = 0,
    intensity = 0,
    speed = 0,
    speedTimer = 0,
    fade = true,
    fadeSpeed = SHAKE_FADE_SPEED,
    dir = 1,
    offsetX = 0,
}

---Snap a world-space camera coordinate to the nearest screen pixel.
---@param value number Coordinate value in world pixels
---@param scale number Current camera scale
---@return number snappedValue
local function snapToScreenPixel(value, scale)
    return math.floor(value * scale + 0.5) / scale
end

---Return whether the player's physics velocity is below the camera settle threshold.
---@param player Soul Entity with an optional vessel field
---@return boolean stopped
local function isPlayerStopped(player)
    if not player.vessel then
        return false
    end

    local vx, vy = player.vessel:getLinearVelocity()
    return vx * vx + vy * vy <= CAMERA_STOPPED_SPEED * CAMERA_STOPPED_SPEED
end

---Clamp a camera center point so the viewport never exceeds map bounds.
---@param x number Camera center X in world pixels
---@param y number Camera center Y in world pixels
---@param map {width: number, height: number, tilewidth: number, tileheight: number} STI map bounds
---@return number clampedX
---@return number clampedY
local function clampToMap(x, y, map)
    local mapWidth = map.width * map.tilewidth
    local mapHeight = map.height * map.tileheight
    local halfViewW = love.graphics.getWidth() / (2 * cam.scale)
    local halfViewH = love.graphics.getHeight() / (2 * cam.scale)
    local minX = halfViewW
    local maxX = mapWidth - halfViewW
    local minY = halfViewH
    local maxY = mapHeight - halfViewH
    local clampedX = x
    local clampedY = y

    if minX > maxX then
        clampedX = mapWidth / 2
    else
        clampedX = math.max(minX, math.min(maxX, clampedX))
    end

    if minY > maxY then
        clampedY = mapHeight / 2
    else
        clampedY = math.max(minY, math.min(maxY, clampedY))
    end

    return clampedX, clampedY
end

---Compute the clamped target camera center for the current map bounds.
---@param player Soul Entity with x and y fields representing its center position
---@param map {width: number, height: number, tilewidth: number, tileheight: number} STI map bounds
---@return number targetX
---@return number targetY
local function getFollowTarget(player, map)
    return clampToMap(player.x, player.y, map)
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
    local drawX, drawY = cam.x + shake.offsetX, cam.y
    cam.x = snapToScreenPixel(drawX, scale)
    cam.y = snapToScreenPixel(drawY, scale)
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
---@param map {width: number, height: number, tilewidth: number, tileheight: number} STI map bounds
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
---@param map {width: number, height: number, tilewidth: number, tileheight: number} STI map bounds
---@return nil
function lens.snapTo(player, map)
    local targetX, targetY = getFollowTarget(player, map)
    cam:lookAt(targetX, targetY)
end

---Start a short horizontal camera shake.
---@param duration? number Duration at full intensity in seconds
---@param intensity? number Horizontal offset amount in world pixels
---@param speed? number Seconds between direction flips
---@param fade? boolean Whether to fade out after duration
---@param fadeSpeed? number Intensity fade speed in pixels per second
---@return nil
function lens.shake(duration, intensity, speed, fade, fadeSpeed)
    shake.time = duration or SHAKE_DURATION
    shake.intensity = intensity or SHAKE_INTENSITY
    shake.speed = speed or SHAKE_SPEED
    shake.speedTimer = shake.speed
    shake.fade = fade ~= false
    shake.fadeSpeed = fadeSpeed or SHAKE_FADE_SPEED
    shake.dir = 1
    shake.offsetX = shake.intensity * shake.dir
end

---Advance the active camera shake. Call after normal follow logic.
---@param dt number Delta time in seconds
---@return nil
function lens.update(dt)
    if shake.time > 0 then
        shake.time = math.max(0, shake.time - dt)
    end

    if shake.time > 0 or (shake.fade and shake.intensity > 0) then
        shake.offsetX = shake.intensity * shake.dir

        if shake.speedTimer <= 0 then
            shake.dir = shake.dir * -1
            shake.speedTimer = shake.speed
        else
            shake.speedTimer = math.max(0, shake.speedTimer - dt)
        end

        if shake.time <= 0 and shake.fade and shake.intensity > 0 then
            shake.intensity = math.max(0, shake.intensity - dt * shake.fadeSpeed)
            if shake.intensity <= 0 then
                shake.offsetX = 0
            end
        end
    else
        shake.offsetX = 0
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
