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

    ../../../../user-modules/matugen
    ../../../../user-modules/rofi
    ../../../../user-modules/qt-gtk.nix

    ../../../../user-modules/nixcord.nix

    # ../../../../user-modules/neovim.nix
    ../../../../user-modules/wayland-utils.nix
    ../../../../user-modules/general-packages.nix
  ];

  # hyprland
  user-shared.hyprland.configType = "lua";
  user-shared.hyprland.useMatugen = true;
  # offset 800x taken by eye. In differend monitor setup it should be more meth based, like 840x
  wayland.windowManager.hyprland.extraConfig = ''
  hl.monitor({output="HDMI-A-1",mode="5120x1440@144.00", position="0x0", scale=1.0})
  hl.monitor({output="DP-3",mode="3440x1440@144.00", position="800x-1440", scale=1.0})
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

    # gaming
    wineWow64Packages.stable
    protonup-qt

    # to fix java app (like minecraft) with alsoft err, pass java args with -Dorg.lwjgl.openal.libname=/usr/lib/libopenal.so (you can find lib with nix-index, use nix-locate, then await, then nix-locate libopenal.so)
    jdk

    # allows live tunneling, for exapmle - use local ai proxi 
    ngrok
    # notify daemon
    mako

    # ai stuff
      sillytavern
      lmstudio
      (pkgs.llama-cpp.override { cudaSupport = true; })
  ];

  # example of flatpack usage
  services.flatpak.packages = [
    "org.prismlauncher.PrismLauncher"
  ];
}
