{ inputs, config, ... }:
{
  imports = [
    ../../../../user-shared/accrrsd/settings.nix

    ../../../../user-modules/hyprland
    ../../../../user-modules/niri
    ../../../../user-modules/zsh
    ../../../../user-modules/kitty.nix
    
    ../../../../user-shared/accrrsd/app/ssh.nix
    ../../../../user-shared/accrrsd/app/hyprland
    ../../../../user-shared/accrrsd/app/niri
    ../../../../user-shared/accrrsd/app/ags

    #../../../../user-modules/pywal
    ../../../../user-modules/matugen
    ../../../../user-modules/rofi
    ../../../../user-modules/qt-gtk.nix

    ../../../../user-modules/nixcord.nix

    # enable flatpack for user pckgs
    #inputs.nix-flatpak.homeManagerModules.default
  ];

  wayland.windowManager.hyprland.extraConfig = ''monitor=HDMI-A-1,5120x1440@144.00,auto,1'';
  user-shared.hyprland.colorScheme = "matugen";
  
  user-shared.niri.colorScheme = "matugen";
  user-shared.niri.extraConfig = ''
    output "HDMI-A-1" {
        mode "5120x1440@144.00"
    }
  '';

  user-modules.rofi.colorScheme = "matugen";
  home.stateVersion = "25.11";

  # example of home manager as nixos module usage
  # home.packages = with pkgs; [ cava ];
  
  # example of flatpack usage
  #services.flatpak.packages = [];
}
