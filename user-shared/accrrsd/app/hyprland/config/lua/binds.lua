-- Global keybindings
hl.bind(mod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd(menu .. " -show drun"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | " .. menu .. " -dmenu | cliphist decode | wl-copy"))
hl.bind(mod .. " + S", hl.dsp.layout("togglesplit"))

-- ScreenShots
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mod .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))
hl.bind(mod .. " + SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))

-- Layout change on alt shift
hl.bind("ALT + SHIFT + Alt_L", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"), { release = true, locked = true, dont_inhibit = true })

-- Window manipulation
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pin())
hl.bind(mod .. " + Y", hl.dsp.layout("togglesplit"))

-- Change window focus
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }))

-- Window movement
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))

-- Switch workspaces
for i = 1, 9 do
    hl.bind(mod .. " + " .. tostring(i), hl.dsp.focus({ workspace = i }))
end
hl.bind(mod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move window to workspace
for i = 1, 9 do
    hl.bind(mod .. " + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = i, follow = true }))
end
hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10, follow = true }))

-- Move window to workspace silently
for i = 1, 9 do
    hl.bind(mod .. " + CTRL + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind(mod .. " + CTRL + SHIFT + 0", hl.dsp.window.move({ workspace = 10, follow = false }))
