{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.user-modules.ags;
in
{
  imports = [ inputs.ags.homeManagerModules.default ];

  options.user-modules.ags = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Aylur's GTK Shell (AGS) launcher configuration";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        List of Astal library package names to include in AGS's GJS search path.
        Available library names can be found at:
        https://aylur.github.io/astal/guide/libraries/references#astal-libraries
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ags = {
      enable = true;
      extraPackages = map (name: inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.${name}) cfg.extraPackages;
    };
  };
}