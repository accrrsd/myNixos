{ config, lib, pkgs, ... }:

let
  cfg = config.user-shared.niri;
  niri-matuge-content = builtins.readFile ./color-scheme/niri-matugen.kdl;
  niri-pywal-content = builtins.readFile ./color-scheme/niri-pywal.kdl;
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
    
    # needed because stable niri is less than 26.06 and dont have absolute paths
    xdg.configFile."niri/color-schemes/niri-matugen.kdl".text = ''
      ${niri-matuge-content}
      include "${config.xdg.configHome}/niri/colors.kdl"
    '';
    
    xdg.configFile."niri/color-schemes/niri-pywal.kdl".text = ''
      ${niri-pywal-content}
      include "${config.xdg.configHome}/niri/colors.kdl"
    '';

    xdg.configFile."niri/config.kdl".text = ''
      ${lib.optionalString (cfg.colorScheme == "matugen") ''include "${config.xdg.configHome}/niri/color-schemes/niri-matugen.kdl"''}
      ${lib.optionalString (cfg.colorScheme == "pywal") ''include "${config.xdg.configHome}/niri/color-schemes/niri-pywal.kdl"''}
      
      include "${config.xdg.configHome}/niri/config-files/env.kdl"
      include "${config.xdg.configHome}/niri/config-files/exec.kdl"
      include "${config.xdg.configHome}/niri/config-files/rules.kdl"
      include "${config.xdg.configHome}/niri/config-files/general.kdl"
      include "${config.xdg.configHome}/niri/config-files/binds.kdl"
      
      ${cfg.extraConfig}
    '';
  };
}