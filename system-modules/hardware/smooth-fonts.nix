{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    fontconfig = {
      enable = true;
      antialias = true;

      hinting.enable = true;
      hinting.style = "slight";
      
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };

      defaultFonts = {
        serif = [ "Noto Serif" "Source Serif Pro" ];
        sansSerif = [ "Inter" "Lexend" ];
        monospace = [ "JetBrainsMono Nerd Font" "JetBrains Mono" ];
      };
    };
  };

  fonts.packages = with pkgs; [
    inter
    lexend
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  environment.variables = {
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
  };
}



