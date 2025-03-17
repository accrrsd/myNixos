
{ inputs, pkgs, ... }:

{
  imports = [
    ./hyprland-config.nix
    ./hypridle-config.nix
    ./hyprlock-config.nix
    ./hyprpaper-config.nix
    ./waybar/waybar.nix
  ];

  home.packages = with pkgs; [
    hyprland
    hyprpaper
    hypridle
    hyprlock
    waybar
    wofi

    dunst
    libnotify
    wlsunset
    vlc
    libinput
    python312Packages.toggl-cli
    kitty
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
