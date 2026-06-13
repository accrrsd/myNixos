local gaming_key = "F19"
hl.bind(gaming_key, hl.dsp.submap("gaming"))

-- Gaming submap where CTRL window/mouse movement bindings are disabled
hl.define_submap("gaming", function()
    dofile(os.getenv("HOME") .. "/.config/hypr/config-files/lua/binds.lua")
    hl.bind(gaming_key, hl.dsp.submap("reset"))
end)

-- Reset back to normal mode
hl.define_submap("reset", function()
    hl.bind("CTRL + mouse:272", hl.dsp.window.drag())
    hl.bind("CTRL + mouse:273", hl.dsp.window.resize())
end)

-- Default bindings in normal mode
hl.bind("CTRL + mouse:272", hl.dsp.window.drag())
hl.bind("CTRL + mouse:273", hl.dsp.window.resize())
