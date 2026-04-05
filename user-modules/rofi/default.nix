{ config, pkgs, lib, ... }:

let
  cfg = config.user-modules.rofi;
  themeDir = cfg.themeDir;

  rasiFileNames = builtins.attrNames (
    lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".rasi" name)
      (builtins.readDir themeDir)
  );

  importLine = if cfg.colorScheme == "pywal"
    then builtins.readFile ./pywal-colors.rasi
    else builtins.readFile ./matugen-colors.rasi;

  processedFiles = lib.listToAttrs (map (fileName: {
    name = "rofi/${fileName}";
    value = {
      source = pkgs.writeText fileName "${importLine}\n${builtins.readFile "${toString themeDir}/${fileName}"}";
    };
  }) rasiFileNames);
in
{
  options.user-modules.rofi = {
    colorScheme = lib.mkOption {
      type = lib.types.enum [ "pywal" "matugen" ];
      default = "pywal";
      description = "Color scheme for rofi.";
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