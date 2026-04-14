---A grab bag of utility functions.
---@class util
local util = {}

---Executes a drawing callback with a fully isolated graphics state.
---Saves all graphics state (color, font, blend mode, transform, etc.) before
---calling `fn`, then restores it afterward using love.graphics push/pop.
---Use this anywhere temporary graphics state changes (setColor, setFont, etc.)
---must not leak into the surrounding draw pipeline.
---@param fn fun() Drawing callback to execute in isolation
function util.safeDraw(fn)
	love.graphics.push("all")
	fn()
	love.graphics.pop()
end

return util
