{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    adw-gtk3 # GTK3 theme

    libsForQt5.qt5ct # qt5ct
    kdePackages.qt6ct # qt6ct

    libsForQt5.qtstyleplugin-kvantum # Kvantum for Qt5
    kdePackages.qtstyleplugin-kvantum # Kvantum for Qt6

    # addition for gtk theme in qt
    qadwaitadecorations
    qadwaitadecorations-qt6
  ];

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  gtk = {
    enable = true;
    # works perfect for matugen, if you need change it - make sure you change matugen/config.toml part too.
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    gtk4.theme = null;
    #gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    #gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
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