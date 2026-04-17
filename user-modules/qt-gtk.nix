{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    adw-gtk3                                # Тема GTK3
    
    # Конфигураторы (теперь они живут тут)
    libsForQt5.qt5ct                        # qt5ct
    kdePackages.qt6ct                       # qt6ct

    libsForQt5.qtstyleplugin-kvantum        # Kvantum для Qt5
    kdePackages.qtstyleplugin-kvantum       # Kvantum для Qt6
    
    # Дополнительно: чтобы Qt-приложения понимали GTK-цвета
    qadwaitadecorations
    qadwaitadecorations-qt6
  ];

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  home.sessionVariables = {
    #QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };
}