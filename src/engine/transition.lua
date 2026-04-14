---@class transition
local transition = {}

transition.alpha = 0
transition.isActive = false

---Perform a fade-out → callback → fade-in transition.
---@param duration number Time in seconds for each half (out and in)
---@param onMidpointFn fun() Called when screen is fully black
---@param onCompleteFn? fun() Called when fade-in finishes
function transition.fade(duration, onMidpointFn, onCompleteFn)
	if transition.isActive then
		return
	end
	transition.isActive = true

	Flux.to(transition, duration, { alpha = 1 }):ease("quadin"):oncomplete(function()
		onMidpointFn()

		Flux.to(transition, duration, { alpha = 0 }):ease("quadout"):oncomplete(function()
			transition.isActive = false
			if onCompleteFn then
				onCompleteFn()
			end
		end)
	end)
end

---Draw the black overlay. Call every frame from the draw pipeline.
function transition.draw()
	if transition.isActive then
		Util.safeDraw(function()
			love.graphics.setColor(0, 0, 0, transition.alpha)
			love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
		end)
	end
end

return transition
