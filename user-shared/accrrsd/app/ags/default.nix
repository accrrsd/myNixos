{ inputs, pkgs, ... }:
{
  # for config reference - use ags init -d <path to src folder> and MAYBE ags types -d <path to src> ? Then rebuild and restart ide.
  
  # add the home manager module
  imports = [ inputs.ags.homeManagerModules.default ];

  home.packages = [ inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.notifd ];

  programs.ags = {
    enable = true;

    # symlink to ~/.config/ags
    configDir = ./src;

    # additional packages and executables to add to gjs's runtime
    extraPackages = with pkgs; [
      
    ];
  };
}