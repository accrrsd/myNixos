{ config, pkgs, inputs, pkgsUnstable, lib, ... }: {

  # for the first time use pywalfox install
  # uses unstable pkgs
  home.packages = (with pkgsUnstable; [matugen]) ++ (with pkgs; [swww rofi pywalfox-native]) ++ (import ./scripts { inherit pkgs; });

  xdg.configFile."matugen/config.toml".source = config.lib.file.mkOutOfStoreSymlink ./config.toml;
  xdg.configFile."matugen/templates".source = config.lib.file.mkOutOfStoreSymlink ./templates;

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=matugen
  '';

  gtk = {
    enable = true;
    gtk3.extraCss = ''@import "colors.css";'';
    gtk4.extraCss = ''@import "colors.css";'';
  };

  # if it dint work - there is util named - qtengine

  qt = {
    enable = true;
    qt5ctSettings = {
      Appearance = {
        color_scheme_path = "${config.home.homeDirectory}/.config/qt5ct/colors/matugen.conf";
        custom_palette = true;
        style = "kvantum";
        icon_theme = "Papirus-Dark";
        standard_dialogs = "xdgdesktopportal";
      };
    };
    
    qt6ctSettings = {
      Appearance = {
        color_scheme_path = "${config.home.homeDirectory}/.config/qt6ct/colors/matugen.conf";
        custom_palette = true;
        style = "kvantum";
        icon_theme = "Papirus-Dark";
        standard_dialogs = "xdgdesktopportal";
      };
    };
  };

  # WARNING ! it's disable kde globals file for editing ! - If you need it, u can write script, or write it manually in ./config/kdeglobals

  xdg.configFile."kdeglobals".text = lib.mkAfter ''
    [UiSettings]
    ColorScheme=qt6ct
  '';
}