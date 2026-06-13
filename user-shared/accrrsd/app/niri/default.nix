{ config, lib, pkgs, ... }:

let
  cfg = config.user-shared.niri;
  niri-matugen-content = builtins.readFile ./color-scheme/niri-matugen.kdl;
in {
  options.user-shared.niri = {
    useMatugen = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use matugen theming";
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
      ${niri-matugen-content}
      include "${config.xdg.configHome}/niri/colors.kdl"
    '';

    xdg.configFile."niri/config.kdl".text = ''
      ${lib.optionalString cfg.useMatugen ''include "${config.xdg.configHome}/niri/color-schemes/niri-matugen.kdl"''}
      
      include "${config.xdg.configHome}/niri/config-files/env.kdl"
      include "${config.xdg.configHome}/niri/config-files/exec.kdl"
      include "${config.xdg.configHome}/niri/config-files/rules.kdl"
      include "${config.xdg.configHome}/niri/config-files/general.kdl"
      include "${config.xdg.configHome}/niri/config-files/binds.kdl"
      
      ${cfg.extraConfig}
    '';
  };
}