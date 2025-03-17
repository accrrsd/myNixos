{ inputs, pkgs, ... }:

{ 
  wayland.windowManager.hyprland = {
  enable = true;
  systemd.enable = true;
  xwayland.enable = true;
  settings = {
    monitor = [
      "DP-1,3440x1440@144.00,auto,auto"
    ];
    exec-once = [
      "hyprpaper"
        "pgrep -x waybar || waybar &"
    ];
    env = [
      "XCURSOR_SIZE,24"
      "LIBVA_DRIVER_NAME,nvidia"
      "XDG_SESSION_TYPE,wayland"
      "GBM_BACKEND,nvidia-drm"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "NVD_BACKEND,direct"
    ];
    input = {
      kb_layout = "us,ru";
      kb_variant = "";
      kb_model = "";
      kb_rules = "";
      kb_options = "grp:alt_shift_toggle";
      follow_mouse = 1;
    };
    general = {
      gaps_in = 3;
      gaps_out = 7;
      border_size = 0;
      resize_on_border = true;
      layout = "dwindle";
      sensivity = -0.09;
    };

    decoration = {
      rounding = 10;
      active_opacity = 0.7;
      inactive_opacity = 0.7;
      dim_inactive = false;
      dim_strength = 0.4;
      blur = {
        enabled = true;
        size = 15;
        passes = 3;
        popups = true;
      };
    };
    animations = {
      enabled = true;
      bezier = [
        "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
      ];
      animation = [
        "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 200, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
      ];
    };
    dwindle = {
      pseudotile = true;
      preserve_split = true;
      force_split = 2;
      default_split_ratio = 1.2;
    };
    gestures = {
      workspace_swipe = false;
    };
    "$mod" = "SUPER";
    "$term" = "wezterm";
    "$filemanager" = "dolphin";
    "$browser" = "firefox";
    bind = [
      "$mod, Q, exec, $term"
        "$mod, W, killactive"
        "$mod, E, exec, $filemanager"
        "$mod, T, togglefloating"
        "$mod, SPACE, exec, wofi"
        "$mod, S, togglesplit"
        "$mod, Z, exec, $browser"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
        "$mod, B, exec, pgrep -x waybar && pkill waybar || waybar &"
        "$mod, P, exec, ~/.config/hypr/hyprwall.sh"
        "$mod SHIFT, E, exit"
    ] ++ (
        builtins.concatLists (builtins.genList (
            i: let
            ws = i + 1;
            in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
            ) 9)
        );
    bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
    ];
  };
 };
}
