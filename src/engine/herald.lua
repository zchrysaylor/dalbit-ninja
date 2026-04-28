---Lightweight pub/sub event bus with a Shakespearean twist.
---@class herald
local herald = {}

---@alias EventCallback fun(...: any): boolean|nil
---  Callback signature for event handlers. Receives whatever arguments were
---  passed to `Herald.decree`. Return `false` to stop propagation to
---  subsequent handlers; any other return value (including `nil`) continues it.

---@alias Unhearken fun(): boolean|nil
---  Returned by `herald.hearken`. Call it to remove the most-recently registered
---  copy of the original callback. Returns `true` if the callback was found
---  and removed, or `nil` if it was not present.

---@alias MusteredUnhearken fun(): boolean|nil

---@class HeraldHearken
---@field unhearken MusteredUnhearken

---@class HeraldMuster
---@field hearken fun(self: HeraldMuster, name: string, callback: EventCallback): HeraldHearken
---@field unhearken fun(self: HeraldMuster, hearken: HeraldHearken): boolean|nil
---@field unhearkenAll fun(self: HeraldMuster)

local handlers = {}
local emitting = {}

---Subscribe a callback to a named event.
---@param name string Unique event name (e.g. "player:died", "map:loaded").
---@param callback EventCallback Function to call when the event is dispatched.
---@return Unhearken A function that, when called, removes this subscription.
function herald.hearken(name, callback)
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
				if emitting[list] then
					list[i] = nil -- safe, no table shift
					emitting[list] = "dirty"
				else
					table.remove(list, i) -- compact immediately
				end
				return true
			end
		end
	end
end

---Dispatch a named event, calling each registered handler in order.
---@param name string The event name to dispatch.
---@param ... any Optional arguments forwarded to each handler.
---@return true|nil `true` if propagation was halted, else `nil`.
function herald.decree(name, ...)
	local list = handlers[name]
	if not list then
		return
	end

	-- capture list length before emission; Lua's # is only guaranteed on sequences,
	-- and this also ensures handlers connected mid-emission don't fire in the current cycle
	local n = #list

	-- emit event/run callback function
	emitting[list] = true
	for i = 1, n do
		local cb = list[i]
		if cb and cb(...) == false then
			if emitting[list] == "dirty" then
				emitting[list] = nil
				Herald.compact(list, n)
			else
				emitting[list] = nil
			end
			return true
		end
	end
	local dirty = emitting[list] == "dirty"
	emitting[list] = nil

	-- compact potential nils introduced from mid-flight unsubs during emission
	-- only compacts if needed, common path (no mid-flight unsubs) can skip this step
	if dirty then
		herald.compact(list, n)
	end
end

---Compact a handler list in-place, removing nil slots left by mid-flight unsubs.
---`listLength` must be the length captured *before* emission so that slots appended
---during emission (beyond the original boundary) are not touched.
---@param list table The handler list to compact.
---@param listLength number The number of entries to inspect (pre-emission `#list`).
---@return nil
function herald.compact(list, listLength)
	local j = 0
	for i = 1, listLength do
		if list[i] then
			j = j + 1
			list[j] = list[i]
		end
	end
	for i = j + 1, listLength do
		list[i] = nil
	end
end

---Create a group to which to assign hearkens and unhearken all simultaneously.
---Useful when one file has many connections.
---@return HeraldMuster
function herald.muster()
	local hearkens = {}
	local nextIndex = 0

	local function unhearkenHearken(hearken)
		if not hearken or not hearken.unhearken then
			return
		end

		return hearken.unhearken()
	end

	return {
		hearken = function(self, name, callback)
			local isActive = true
			nextIndex = nextIndex + 1
			local index = nextIndex
			local unhearken = herald.hearken(name, callback)
			local hearken = {}

			hearken.unhearken = function()
				if not isActive then
					return
				end

				isActive = false
				hearkens[index] = nil
				return unhearken()
			end

			hearkens[index] = hearken
			return hearken
		end,
		unhearken = function(self, hearken)
			return unhearkenHearken(hearken)
		end,
		unhearkenAll = function(self)
			for index, hearken in pairs(hearkens) do
				unhearkenHearken(hearken)
				hearkens[index] = nil
			end
			hearkens = {}
		end,
	}
end

---Remove handlers for a single event, or clear the entire event bus.
---@param name? string Event name to clear. If `nil`, all events are cleared.
---@return nil
function herald.clear(name)
	if name then
		handlers[name] = nil
	else
		handlers = {}
		emitting = {}
	end
end

return herald
