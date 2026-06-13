{ config, lib, pkgs, ... }:

let
  cfg = config.user-shared.hyprland;
in {
  options.user-shared.hyprland = {
    useMatugen = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use matugen theming";
    };

    configType = lib.mkOption {
      type = lib.types.enum [ "lua" "hyprconf" ];
      default = "hyprconf";
      description = "Which config scheme to use"; 
    };
  };

  config = {
    xdg.configFile."hypr/config-files".source = ./config;
    xdg.configFile."hypr/color-schemes".source = ./color-scheme;

    wayland.windowManager.hyprland.configType = cfg.configType;

    wayland.windowManager.hyprland.extraConfig = 
      lib.optionalString (cfg.configType == "lua") ''
        ${lib.optionalString cfg.useMatugen "require('color-schemes/hypr-matugen')"}

        require("config-files/lua/env")
        require("config-files/lua/exec")
        require("config-files/lua/rules")
        require("config-files/lua/general")
        require("config-files/lua/vars")
        require("config-files/lua/submaps")
        require("config-files/lua/binds")
      '' 
      +
      lib.optionalString (cfg.configType == "hyprconf") ''
        ${lib.optionalString cfg.useMatugen "source = ~/.config/hypr/color-schemes/hypr-matugen.conf"}

        source = ~/.config/hypr/config-files/hyprconf/env.conf
        source = ~/.config/hypr/config-files/hyprconf/exec.conf
        source = ~/.config/hypr/config-files/hyprconf/rules.conf
        source = ~/.config/hypr/config-files/hyprconf/general.conf
        source = ~/.config/hypr/config-files/hyprconf/vars.conf
        source = ~/.config/hypr/config-files/hyprconf/submaps.conf
        source = ~/.config/hypr/config-files/hyprconf/binds.conf
      '';
  };
}

