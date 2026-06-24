{ config, pkgs, lib, ... }:
{
  # Enable AGS and pass package names as strings
  user-modules.ags = {
    enable = true;
    extraPackages = [ "notifd" "apps" ];
  };

  programs.ags.configDir = ./src;

  home.packages = [
    pkgs.libqalculate
  ];

  # Write configuration JSON file
  xdg.configFile."ags-launcher.json".text = builtins.toJSON {
    # Proportion of gaps from Hyprland config (0.0 to 1.0)
    gaps_proportion = 0.33;
    # Font style used in the launcher
    launcher_font = "14pt Hack Nerd Font, sans-serif";
    # Icon size multiplier relative to font size
    launcher_icon_size_multiplayer = 1.25;
    # Height mode of the window:
    # "fancy" - dynamic size that wraps around search items
    # "full"  - static size for exactly 8 search items
    height_mode = "fancy";
    # Settings for "fancy" height mode animations
    fancy_settings = {
      # Time delay in seconds between stagger reveal steps (e.g. 0.02 for 20ms)
      speed = 0.02;
      # Folding behavior when clearing search query:
      # "sequential"            - step-by-step collapse with delay
      # "simultaneous"          - instant simultaneous collapse of all slots
      # "simultaneous-debounce" - simultaneous collapse delayed by speed * 4 (prevents accidental folds on fast typing)
      fold_type = "sequential";
      # Transition duration in milliseconds for the Gtk.Revealer slide animation.
      # Set to null to calculate dynamically based on: speed * 8 * 1000
      transition_duration = null;
    };
    commands = {
      c = {
        type = "calc";
        name = "Calculator";
        icon = "accessories-calculator";
      };
      t = {
        type = "time";
        name = "Time & Date";
        icon = "preferences-system-time";
      };
      "!" = {
        type = "launch";
        exec = "{args}";
        name = "Run Shell Command";
        icon = "utilities-terminal";
      };
      yi = {
        type = "launch";
        exec = "xdg-open \"https://yandex.ru/images/search?text={urlargs}\"";
        name = "Yandex Images";
        icon = "applications-internet";
      };
      w = {
        type = "launch";
        exec = "select-wallpaper";
        name = "Wallpaper Selector";
        icon = "background";
      };
      yt = {
        type = "launch";
        exec = "xdg-open \"https://www.youtube.com/results?search_query={urlargs}\"";
        name = "Youtube";
        icon = "applications-internet";
      };
    };
  };
}