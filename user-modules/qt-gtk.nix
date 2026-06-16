{ pkgs, lib, config, ... }:

{
  home.packages = with pkgs; [
    adw-gtk3 # GTK3 theme

    # libsForQt5.qt5ct # qt5ct
    # kdePackages.qt6ct # qt6ct

    # libsForQt5.qtstyleplugin-kvantum # Kvantum for Qt5
    # kdePackages.qtstyleplugin-kvantum # Kvantum for Qt6

    # addition for gtk theme in qt
    # qadwaitadecorations
    # qadwaitadecorations-qt6
  ];

  # KISS. Qt theming is insane. PlatformTheme - something like backend, when style is frontend. 
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "kvantum";
  };

  gtk = {
    enable = true;
    # works perfect for matugen, if you need change it - make sure you change matugen/config.toml part too.
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    # gtk 3-4 fix nix 26v
    gtk3 = {
      enable = true;
      theme = config.gtk.theme;
      colorScheme = "dark";
    };
    gtk4 = {
      enable = true;
      theme = config.gtk.theme;
      colorScheme = "dark";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      # is color-scheme really needed? I affraid of matugen conflict, but if matugen light work - its ok.
      gtk-theme = config.gtk.theme.name;
      color-scheme = "prefer-dark";
    };
  };

  xresources.properties = {
    "Xft.antialias" = 1;
    "Xft.hinting" = 1;
    "Xft.autohint" = 0;
    "Xft.hintstyle" = "hintslight";
    "Xft.rgba" = "rgb";
    "Xft.lcdfilter" = "lcddefault";
  };

  # WARNING ! it's disable kde globals file for editing ! - If you need it, u can write script, or write it manually in ./config/kdeglobals
  xdg.configFile."kdeglobals".text = lib.mkAfter ''
    [UiSettings]
    ColorScheme=qt6ct
  '';

  # also needed as home pkgs
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
}