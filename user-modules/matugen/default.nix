{ config, pkgs, inputs, lib, ... }: {

  # for the first time use pywalfox install.
  
  # uses unstable pkgs
  home.packages = [ pkgs.unstable.matugen ] ++ (with pkgs; [ awww ]) ++ [ pkgs.oldpkgs.pywalfox-native ] ++ (import ./scripts { inherit pkgs; });

  xdg.configFile."matugen/config.toml".source = ./config.toml;
  xdg.configFile."matugen/templates".source = ./templates;
  xdg.configFile."matugen/post-hook-scripts".source = ./post-hook-scripts;

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
}