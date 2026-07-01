-- Startup commands equivalent to exec-once
hl.on("hyprland.start", function ()
    -- Fix slow startup
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_THEME")
    hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_THEME QT_QPA_PLATFORMTHEME")
    
    -- polkit agent
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- openrgb start
    hl.exec_cmd("~/.config/matugen/post-hook-scripts/openrgb.sh")

    -- firefox theming
    hl.exec_cmd("pywalfox start")
    
    -- wallpapers
    hl.exec_cmd("awww-daemon")
    
    -- blue light filter — starts daemon and sets temperature after 2s delay
    hl.exec_cmd("sh -c 'wl-gammarelay-rs & sleep 2; busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 4500'")
    
    -- clipboard
    hl.exec_cmd("wl-clip-persist --clipboard regular --display wayland-1")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- ags
    hl.exec_cmd("ags run")
end)
