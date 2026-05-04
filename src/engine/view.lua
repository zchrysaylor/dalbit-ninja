---Screen-space view helpers. Computes the camera zoom needed to keep the
---base gameplay height consistent with the current window size.
---@class view
local view = {}

local BASE_VIEW_HEIGHT = WINDOW_HEIGHT / 5
assert(BASE_VIEW_HEIGHT == math.floor(BASE_VIEW_HEIGHT),
	"BASE_VIEW_HEIGHT must be an integer to avoid pixel shimmer")

---Get the current drawable window width in pixels.
---@return number
function view.getWidth()
	return love.graphics.getWidth()
end

---Get the current drawable window height in pixels.
---@return number
function view.getHeight()
	return love.graphics.getHeight()
end

---Get the current camera zoom scale.
---@return number
function view.getScale()
	return view.getHeight() / BASE_VIEW_HEIGHT
end

return view
