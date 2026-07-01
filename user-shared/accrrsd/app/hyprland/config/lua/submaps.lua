local gaming_key = "F19"
local is_gaming_mode = false
local last_toggle_time = 0

hl.bind("CTRL + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("CTRL + mouse:273", hl.dsp.window.resize(), { mouse = true })

local function toggle_gaming_mode()
    local current_time = os.clock()
    if (current_time - last_toggle_time) < 0.2 then return end
    last_toggle_time = current_time

    if not is_gaming_mode then
        is_gaming_mode = true
        hl.unbind("CTRL + mouse:272")
        hl.unbind("CTRL + mouse:273")
        hl.dispatch(hl.dsp.exec_cmd('notify-send "Block Window Mouse"'))
    else
        is_gaming_mode = false
        hl.bind("CTRL + mouse:272", hl.dsp.window.drag(), { mouse = true })
        hl.bind("CTRL + mouse:273", hl.dsp.window.resize(), { mouse = true })
        hl.dispatch(hl.dsp.exec_cmd('notify-send "Unblock Window Mouse"'))
    end
end

hl.bind(gaming_key, toggle_gaming_mode)