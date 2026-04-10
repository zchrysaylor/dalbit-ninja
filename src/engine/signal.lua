---Lightweight pub/sub event bus.
---@module signal
local signal = {}

---@alias EventCallback fun(...: any): boolean|nil
---  Callback signature for event handlers. Receives whatever arguments were
---  passed to `signal.emit`. Return `false` to stop propagation to
---  subsequent handlers; any other return value (including `nil`) continues it.

---@alias Unsubscribe fun(): boolean|nil
---  Returned by `signal.connect`. Call it to remove the most-recently registered
---  copy of the original callback. Returns `true` if the callback was found
---  and removed, or `nil` if it was not present.

local handlers = {}

---Subscribe a callback to a named event.
---@param name string Unique event name (e.g. "player:died", "map:loaded").
---@param callback EventCallback Function to call when the event is dispatched.
---@return Unsubscribe A function that, when called, removes this subscription.
function signal.connect(name, callback)
	local list = handlers[name]
	-- lazy initialization; unused events incur no allocation cost
	if not list then
		list = {}
		handlers[name] = list
	end
	list[#list + 1] = callback
	return function()
		-- backwards search; only most recent registration removed
		for i = #list, 1, -1 do
			if list[i] == callback then
				list[i] = nil
				return true
			end
		end
	end
end

---Dispatch a named event, calling each registered handler in order.
---@param name string The event name to dispatch.
---@param ... any Optional arguments forwarded to each handler.
---@return true|nil `true` if propagation was halted, else `nil`.
function signal.emit(name, ...)
	local list = handlers[name]
	if not list then
		return
	end

	local dirty = false
	for i = 1, #list do
		local cb = list[i]
		if cb then
			if cb(...) == false then
				return true
			end
		else
			dirty = true
		end
	end

	-- clean up unsubbed callbacks with an in-place compaction algorithm
	if dirty then
		local j = 0
		for i = 1, #list do
			if list[i] then
				j = j + 1
				list[j] = list[i]
			end
		end
		for i = j + 1, #list do
			list[i] = nil
		end
	end
end

-- TODO: implement for map transitions and state exits
---Remove handlers for a single event, or clear the entire event bus.
---@param name? string Event name to clear. If `nil`, all events are cleared.
function signal.clear(name)
	if name then
		local list = handlers[name]
		if list then
			for i = 1, #list do
				list[i] = nil
			end
		end
		handlers[name] = nil
	else
		for k, list in pairs(handlers) do
			for i = 1, #list do
				list[i] = nil
			end
			handlers[k] = nil
		end
	end
end

return signal
