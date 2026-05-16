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
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
    };
  };
}
