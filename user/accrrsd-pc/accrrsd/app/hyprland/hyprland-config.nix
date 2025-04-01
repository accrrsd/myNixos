{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
  };

  wayland.windowManager.hyprland.extraConfig = ''
    # Fix slow startup
    exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    exec-once = dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

    exec-once = swww-daemon
    exec-once = dunst
    exec-once = waybar

    #exec-once = wl-clipboard-history -t
    exec-once = wl-clip-persist --clipboard regular --display wayland-1
    
    exec-once = wl-paste --type text --watch cliphist store
    exec-once = wl-paste --type image --watch cliphist store

    exec = swww img /home/accrrsd/Pictures/red-tree.jpg

    #themes
    exec = gsettings set org.gnome.desktop.interface gtk-theme "YOUR_DARK_GTK3_THEME"   # for GTK3 apps
    exec = gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"   # for GTK4 apps
    env = QT_QPA_PLATFORMTHEME,qt5ct   # for Qt apps

    #env = XCURSOR_SIZE,24
    #env = HYPRCURSOR_SIZE,24

    # needed for fix flickering with electon
    env = ELECTRON_OZONE_PLATFORM_HINT,auto

    # nvidia specific trash from hyprland wiki, maybe its not needed, cuase we on nixos https://wiki.hyprland.org/0.41.2/Nvidia/
    #env = LIBVA_DRIVER_NAME,nvidia
    #env = XDG_SESSION_TYPE,wayland
    #env = GBM_BACKEND,nvidia-drm
    #env = __GLX_VENDOR_LIBRARY_NAME,nvidia
    #env = NVD_BACKEND,direct
  
    # IDK
    #env = __GL_VRR_ALLOWED,1;
    #env = WLR_RENDERER_ALLOW_SOFTWARE,1;
    #env = CLUTTER_BACKEND,wayland;

    $terminal = wezterm #kitty
    $fileManager = dolphin
    $browser = firefox
    $menu = wofi

    monitor=DP-1,3440x1440@144.00,auto,1

    input {
      kb_layout = us,ru
      follow_mouse = 2
      kb_options = grp:alt_shift_toggle

      sensitivity = -0.1 # -1.0 - 1.0, 0 means no modification.

      accel_profile = flat
      force_no_accel = 1
    }

    general {
      gaps_in = 3
      gaps_out = 7
      border_size = 2

      resize_on_border = true
      layout = dwindle
    }

    decoration {
      rounding = 10
      active_opacity = 0.8
      inactive_opacity = 0.8
      dim_inactive = false
      dim_strength = 0.4

      blur {
        enabled = true
        size = 15
        passes = 3
        vibrancy = 0.016
        new_optimizations = on
      }
    }

    animations {
      enabled = true

      bezier = myBezier, 0.05, 0.9, 0.1, 1.05

      animation = windows, 1, 7, myBezier
      animation = windowsOut, 1, 7, default, popin 80%
      animation = border, 1, 10, default
      animation = borderangle, 1, 8, default
      animation = fade, 1, 7, default
      animation = workspaces, 1, 6, default
    }

    dwindle {
      pseudotile = true
      preserve_split = true
    }

    master {
      new_status = master
    }

    misc {
      force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
      disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
    }

    gestures {
      workspace_swipe = false
    }

    $mod = SUPER

    bind = $mod, Q, exec, $terminal
    bind = $mod, W, killactive,
    bind = $mod, E, exec, $fileManager
    bind = $mod, T, togglefloating,
    bind = $mod, SPACE, exec, $menu --show drun
    bind = $mod, J, togglesplit, # dwindle
    bind = $mod, B, exec, $browser
    bind = $mod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy
    bind = $mod, Z, exec, zen
    bind = $mod, backspace, exec, pkill -USR1 waybar || waybar
    bind = $mod, S, swapsplit

    # Window manipulation
    bind = $mod, F,             fullscreen,
    #bind = $mod SHIFT, F,       fakefullscreen,
    bind = $mod, P,             pin

    # if need togglesplit - make hotkey
    #bind = something,            togglesplit,


    # Change window focus
    bind = $mod, up,             movefocus, u
    bind = $mod, right,             movefocus, r
      bind = $mod, down,             movefocus, l
    bind = $mod, left,             movefocus, d

    # Window movement (for tiled windows)
    bind = $mod SHIFT, left,       movewindow, l
    bind = $mod SHIFT, down,       movewindow, d
    bind = $mod SHIFT, up,       movewindow, u
    bind = $mod SHIFT, right,       movewindow, r

    # resize window
    bind = $mod ALT, left,         resizeactive, -200 0
    bind = $mod ALT, down,         resizeactive, 0 200
    bind = $mod ALT, up,         resizeactive, 0 -200
    bind = $mod ALT, right,         resizeactive, 200 0

    # Move/resize windows with mod + LMB/RMB and dragging
    bindm = $mod, mouse:272,    movewindow
    bindm = $mod, mouse:273,    resizewindow

    # Switch workspaces with mod + [0-right]
    bind = $mod, 1, workspace, 1
    bind = $mod, 2, workspace, 2
    bind = $mod, 3, workspace, 3
    bind = $mod, 4, workspace, 4
    bind = $mod, 5, workspace, 5
    bind = $mod, 6, workspace, 6
    bind = $mod, 7, workspace, 7
    bind = $mod, 8, workspace, 8
    bind = $mod, 9, workspace, 9
    bind = $mod, 0, workspace, 10

    # Move active window to a workspace with mod + SHIFT + [0-9]
    bind = $mod SHIFT, 1, movetoworkspace, 1
    bind = $mod SHIFT, 2, movetoworkspace, 2
    bind = $mod SHIFT, 3, movetoworkspace, 3
    bind = $mod SHIFT, 4, movetoworkspace, 4
    bind = $mod SHIFT, 5, movetoworkspace, 5
    bind = $mod SHIFT, 6, movetoworkspace, 6
    bind = $mod SHIFT, 7, movetoworkspace, 7
    bind = $mod SHIFT, 8, movetoworkspace, 8
    bind = $mod SHIFT, 9, movetoworkspace, 9
    bind = $mod SHIFT, 0, movetoworkspace, 10

    # Move window to workspace (without switching to workspace)
    bind = $mod CTRL SHIFT, 1,  movetoworkspacesilent, 1
    bind = $mod CTRL SHIFT, 2,  movetoworkspacesilent, 2
    bind = $mod CTRL SHIFT, 3,  movetoworkspacesilent, 3
    bind = $mod CTRL SHIFT, 4,  movetoworkspacesilent, 4
    bind = $mod CTRL SHIFT, 5,  movetoworkspacesilent, 5
    bind = $mod CTRL SHIFT, 6,  movetoworkspacesilent, 6
    bind = $mod CTRL SHIFT, 7,  movetoworkspacesilent, 7
    bind = $mod CTRL SHIFT, 8,  movetoworkspacesilent, 8
    bind = $mod CTRL SHIFT, 9,  movetoworkspacesilent, 9

    '';
}
