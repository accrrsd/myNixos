local gaming_key = "F19"

hl.bind(gaming_key, hl.dsp.submap("gaming"))

hl.define_submap("gaming", function()
    dofile(os.getenv("HOME") .. "/.config/hypr/config-files/lua/binds.lua")
    hl.bind(gaming_key, hl.dsp.submap("reset"))
end)

hl.bind("CTRL + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("CTRL + mouse:273", hl.dsp.window.resize(), { mouse = true })