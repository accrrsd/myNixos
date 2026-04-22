{ config, lib, pkgs, ... }:

let
  cfg = config.user-shared.hyprland;
in {
  options.user-shared.hyprland = {
    colorScheme = lib.mkOption {
      type = lib.types.enum [ "" "pywal" "matugen" ];
      default = "";
      description = "Which color engine to use";
    };
  };

  config = {
    xdg.configFile."hypr/config-files".source = ./config;
    xdg.configFile."hypr/color-schemes".source = ./color-scheme;

    wayland.windowManager.hyprland.extraConfig = ''
      ${lib.optionalString (cfg.colorScheme == "matugen") "source = ~/.config/hypr/color-schemes/hypr-matugen.conf"}
      ${lib.optionalString (cfg.colorScheme == "pywal") "source = ~/.config/hypr/color-schemes/hypr-pywal.conf"}

      source = ~/.config/hypr/config-files/binds.conf
      source = ~/.config/hypr/config-files/env.conf
      source = ~/.config/hypr/config-files/exec.conf
      source = ~/.config/hypr/config-files/rules.conf
      source = ~/.config/hypr/config-files/general.conf
    '';
  };
}