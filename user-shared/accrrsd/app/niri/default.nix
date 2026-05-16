{ config, lib, pkgs, ... }:

let
  cfg = config.user-shared.niri;
in {
  options.user-shared.niri = {
    colorScheme = lib.mkOption {
      type = lib.types.enum [ "" "pywal" "matugen" ];
      default = "";
      description = "Which color engine to use";
    };
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra configuration to append to Niri config, like monitor settings.";
    };
  };

  config = {
    xdg.configFile."niri/config-files".source = ./config;
    xdg.configFile."niri/color-schemes".source = ./color-scheme;

    xdg.configFile."niri/config.kdl".text = ''
      ${lib.optionalString (cfg.colorScheme == "matugen") ''include "~/.config/niri/color-schemes/niri-matugen.kdl"''}
      ${lib.optionalString (cfg.colorScheme == "pywal") ''include "~/.config/niri/color-schemes/niri-pywal.kdl"''}
      
      include "~/.config/niri/config-files/env.kdl"
      include "~/.config/niri/config-files/exec.kdl"
      include "~/.config/niri/config-files/rules.kdl"
      include "~/.config/niri/config-files/general.kdl"
      include "~/.config/niri/config-files/binds.kdl"
      
      ${cfg.extraConfig}
    '';
  };
}
