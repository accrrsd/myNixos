local wezterm = require("wezterm")
local act = wezterm.action
local c = wezterm.config_builder()


c.font = wezterm.font("FiraCode Nerd Font")
c.font_size = 12.0
c.window_background_opacity = 0.9
c.enable_tab_bar = false
-- disable wayland help with some bugs
c.enable_wayland = false

-- Функция для изменения размера шрифта
local function set_font_size(window, _pane, new_size)
	window:set_config_overrides({ font_size = new_size })
end

-- Обработчик события изменения пользовательской переменной
wezterm.on("user-var-changed", function(window, pane, name, value)
	if name == "WEZTERM_FONT_SIZE" then
		local new_size = tonumber(value)
		if new_size then
			set_font_size(window, pane, new_size)
		end
	end
end)

c.window_decorations = "RESIZE"
c.max_fps = 144
c.automatically_reload_config = true
c.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
c.enable_scroll_bar = false

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	c.default_prog = { "powershell.exe" }
end

c.window_close_confirmation = "NeverPrompt"

-- bugged, use shift ctrl v instead 
-- c.keys = {
-- 	{ key = "v", mods = "CTRL", action = act.PasteFrom("Clipboard") },
-- 	{ key = "v", mods = "CTRL", action = act.PasteFrom("PrimarySelection") },
-- }

return c