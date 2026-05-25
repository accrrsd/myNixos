{ inputs, pkgs, ... }:
{
  # add the home manager module
  imports = [ inputs.ags.homeManagerModules.default ];

  home.packages = [ inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.notifd ];

  programs.ags = {
    enable = true;

    # symlink to ~/.config/ags
    configDir = ./src;

    # additional packages and executables to add to gjs's runtime
    extraPackages = with pkgs; [
      inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.battery
      fzf
    ];
  };
}