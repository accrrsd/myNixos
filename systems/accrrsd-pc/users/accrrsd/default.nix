{ inputs, config, ... }:
{
  imports = [
    ../../../../user-shared/accrrsd/settings.nix

    ../../../../user-modules/hyprland
    ../../../../user-modules/zsh
    ../../../../user-modules/kitty.nix

    ../../../../user-shared/accrrsd/app/waybar
    ../../../../user-shared/accrrsd/app/ssh.nix
    ../../../../user-shared/accrrsd/app/hyprland

    #../../../../user-modules/pywal
    ../../../../user-modules/matugen
    ../../../../user-modules/rofi
    ../../../../user-modules/qt-gtk.nix

    # enable flatpack for user pckgs
    #inputs.nix-flatpak.homeManagerModules.default
  ];

  # wayland.windowManager.hyprland.extraConfig = ''monitor=HDMI-A-1,5120x1440@144.00,auto,1'';
  user-shared.hyprland.colorScheme = "matugen";
  user-modules.rofi.colorScheme = "matugen";

  home.stateVersion = "25.11";

  # example of home manager as nixos module usage
  # home.packages = with pkgs; [
  #   swww
  #   cava
  # ];

  # example of flatpack usage
  #services.flatpak.packages = [

  #];
}
