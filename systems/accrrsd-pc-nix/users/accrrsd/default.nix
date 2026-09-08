{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../../../../user-shared/accrrsd/settings.nix

    ../../../../user-modules/hyprland.nix
    ../../../../user-modules/niri.nix
    ../../../../user-modules/zsh
    ../../../../user-modules/kitty.nix
    ../../../../user-modules/ags.nix

    ../../../../user-shared/accrrsd/app/ssh.nix
    ../../../../user-shared/accrrsd/app/hyprland
    ../../../../user-shared/accrrsd/app/niri
    ../../../../user-shared/accrrsd/app/ags

    ../../../../user-modules/matugen
    ../../../../user-modules/rofi
    ../../../../user-modules/qt-gtk.nix

    ../../../../user-modules/nixcord.nix

    # ../../../../user-modules/neovim.nix
    ../../../../user-modules/utils/general-packages.nix
  ];

  # hyprland
  user-shared.hyprland.configType = "lua";
  user-shared.hyprland.useMatugen = true;
  # offset 800x taken by eye. In differend monitor setup it should be more meth based, like 840x
  wayland.windowManager.hyprland.extraConfig = ''
  hl.monitor({output="HDMI-A-1",mode="5120x1440@144.00", position="0x0", scale=1.0})
  hl.monitor({output="DP-3",mode="3440x1440@144.00", position="950x-1440", scale=1.0})
  hl.workspace_rule({ workspace = "10", monitor = "DP-3", default = true, persistent = true })
  '';

  # niri
  user-shared.niri.useMatugen = true;
  user-shared.niri.extraConfig = ''
    output "HDMI-A-1" {
        mode "5120x1440@143.999"
        scale 1.0
    }
  '';

  # rofi
  user-modules.rofi.useMatugen = true;

  home.stateVersion = "25.11";

  home.packages = with pkgs; [

    # libs
      nodejs
      (python3.withPackages (
        ps: with ps; [
          # pip - maybe not needed, because imperative stuff.
          requests
          numpy
        ]
      ))
      jdk # to fix java app (like minecraft) with alsoft err, pass java args with -Dorg.lwjgl.openal.libname=/usr/lib/libopenal.so (you can find lib with nix-index, use nix-locate, then await, then nix-locate libopenal.so)


    # audio, video, image
      ffmpeg
      vlc
      yt-dlp
      audacity # audio editor
      kdePackages.kdenlive # video editor
      inkscape # vector editor

    # desktop apps
      telegram-desktop
      google-chrome
      obsidian

    # tech stuff
      lazygit
      htop
      ngrok # allows live tunneling, for example - use local ai proxi 

    # gaming
    wineWow64Packages.stable
    protonup-qt

    # ai stuff
      sillytavern
      lmstudio
      (pkgs.llama-cpp.override { cudaSupport = true; })


    # no category
      vmware-workstation # virtual machine manager
      qbittorrent # torrent
      linux-wallpaperengine # live wallpaper 
  ];

  # example of flatpack usage
  services.flatpak.packages = [
    "org.prismlauncher.PrismLauncher"
  ];

  services.flatpak.overrides = {
    "org.prismlauncher.PrismLauncher" = {
      Context = {
        filesystems = [
          # or just "host"
          # "/mnt/hdd1:create"
          "host"
        ];
      };
    };
  };
}
