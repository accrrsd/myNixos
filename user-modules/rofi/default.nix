{ config, pkgs, lib, ... }:

let
  cfg = config.user-modules.rofi;
  themeDir = cfg.themeDir;

  rasiFileNames = builtins.attrNames (
    lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".rasi" name)
      (builtins.readDir themeDir)
  );
  
  importLine = if cfg.useMatugen 
    then "${builtins.readFile ./matugen-colors.rasi.in}" 
    else "";

  processedFiles = lib.listToAttrs (map (fileName: {
    name = "rofi/${fileName}";
    value = {
      source = pkgs.writeText fileName "${importLine}\n${builtins.readFile "${toString themeDir}/${fileName}"}";
    };
  }) rasiFileNames);
in
{
  options.user-modules.rofi = {
    useMatugen = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use matugen theming";
    };

    themeDir = lib.mkOption {
      type = lib.types.path;
      default = ./theme1;
      description = "Directory containing the raw .rasi theme files.";
    };
  };

  config = {
    home.packages = with pkgs; [ rofi ];
    xdg.configFile = processedFiles;
  };
}