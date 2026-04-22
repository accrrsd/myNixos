{ pkgs, lib, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    extraConfig = lib.mkDefault (builtins.readFile ./hyperland.conf);
  };
  
  home.packages = with pkgs; [
    hyprshot
    rofi
    dunst
    brightnessctl
    wl-gammarelay-rs
  ];

  home.activation = {
    reloadHyprland = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
          ${pkgs.hyprland}/bin/hyprctl reload
        fi
    '';
  };
}