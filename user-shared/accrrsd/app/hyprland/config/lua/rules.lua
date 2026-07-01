-- Make file picker windows floating and centered
hl.window_rule({
    match = {
        title = "^(Open File|Open|Save|Save As|Export|Import|Choose File|Rename)$",
        class = "^(.*)$"
    },
    float = true,
    center = true
})

hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" }, float = true, center = true })
hl.window_rule({ match = { class = "Xdg-desktop-portal-gtk" }, float = true, center = true })
hl.window_rule({ match = { class = "xdg-desktop-portal-hyperland" }, float = true, center = true })
hl.window_rule({ match = { class = "Xdg-desktop-portal-hyperland" }, float = true, center = true })
hl.window_rule({ match = { class = "^(steam_app_.*)$" }, float = true, center = true })

-- render unfocused to fix lags in some apps
hl.window_rule({ match = { class = "^(godot)$" }, render_unfocused = true })
hl.window_rule({ match = { class = "^(minecraft)$" }, render_unfocused = true })
hl.window_rule({ match = { class = "^(wine)$" }, render_unfocused = true })
hl.window_rule({ match = { class = "^(steam_app_.*)$" }, render_unfocused = true })

-- AmneziaVPN float and center
hl.window_rule({ match = { title = "^(AmneziaVPN)$" }, float = true, center = true })

-- Rofi rules
hl.layer_rule({ match = { namespace = "rofi" }, animation = "popin 90%" })
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, dim_around = true })

-- Disable animations on screenshot selection layers to prevent selection border in screenshots
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({ match = { namespace = "slurp" }, no_anim = true })

-- make ags launcher slide bottom and blur
hl.layer_rule({ match = { namespace = "launcher" }, animation = "slide bottom" })
-- hl.layer_rule({ match = { namespace = "launcher" }, blur = true })