function love.conf(t)
	t.version = "11.5"

	-- high dpi monitors can mess up shader calculations unless accounted for
	t.modules.highdpi = false

	-- deactivating unused interaction methods
	t.modules.joystick = false
	t.modules.touch = false
	t.modules.mouse = false

	-- t.window.icon = ""
end
