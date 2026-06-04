{
  inputs,
  config,
  pkgs,
  ...
}:
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

    ../../../../user-modules/neovim.nix
    ../../../../user-modules/wayland-utils.nix
    ../../../../user-modules/rgb-control.nix
    ../../../../user-modules/general-packages.nix
  ];

  wayland.windowManager.hyprland.extraConfig = "monitor=HDMI-A-1,5120x1440@144.00,auto,1";
  user-shared.hyprland.colorScheme = "matugen";

  user-shared.niri.colorScheme = "matugen";
  user-shared.niri.extraConfig = ''
    output "HDMI-A-1" {
        mode "5120x1440@143.999"
        scale 1.0
    }
  '';

  user-modules.rofi.colorScheme = "matugen";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    telegram-desktop
    google-chrome
    nodejs
    htop
    qbittorrent
    linux-wallpaperengine
    emote
    obsidian
    vlc
    yt-dlp
    activitywatch

    inputs.antigravity-nix.packages.x86_64-linux.google-antigravity-ide

    (python3.withPackages (
      ps: with ps; [
        pip
        requests
        numpy
      ]
    ))

    wineWow64Packages.stable
    gimp
    # to fix java app (like minecraft) with alsoft err, pass java args with -Dorg.lwjgl.openal.libname=/usr/lib/libopenal.so (you can find lib with nix-index, use nix-locate, then await, then nix-locate libopenal.so)
    jdk
  ];

  # example of flatpack usage
  #services.flatpak.packages = [];
}
