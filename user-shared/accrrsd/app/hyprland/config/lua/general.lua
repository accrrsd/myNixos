hl.config({
  ecosystem = {
    no_update_news = true
  },
  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = false,
    always_follow_on_dnd = true
  },
  dwindle = {
    preserve_split = true,
    smart_split = true
  },
  master = {
    new_status = "master"
  },
  input = {
    kb_layout = "us,ru",
    kb_options = "fkeys:basic_13-24",
    follow_mouse = 2,
    force_no_accel = 1
  },
  render = {
    direct_scanout = 0
  },
  general = {
    gaps_in = 14,
    gaps_out = 30,
    border_size = 4,
    resize_on_border = false,
    layout = "dwindle"
  },
  decoration = {
    rounding = 10,
    active_opacity = 0.9,
    inactive_opacity = 0.9,
    dim_inactive = false,
    dim_strength = 0.4,
    blur = {
      enabled = true,
      size = 8,
      passes = 4,
      new_optimizations = true
    }
  }
})

-- Animation curves
hl.curve("wind", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winIn", { type = "bezier", points = { {0.1, 1.1}, {0.1, 1.1} } })
hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
hl.curve("liner", { type = "bezier", points = { {1, 1}, {1, 1} } })
hl.curve("overshot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("smoothOut", { type = "bezier", points = { {0.5, 0}, {0.99, 0.99} } })
hl.curve("smoothIn", { type = "bezier", points = { {0.5, -0.5}, {0.68, 1.5} } })
hl.curve("easeOutExpo", { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })

-- Animations
hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "smoothOut" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 8, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 6, bezier = "easeOutExpo", style = "slide" })
