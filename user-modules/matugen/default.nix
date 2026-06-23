{ config, pkgs, inputs, lib, ... }: {

  # for the first time use pywalfox install.
  
  # uses unstable pkgs
  home.packages = [ pkgs.unstable.matugen ] ++ (with pkgs; [ awww pastel ]) ++ [ pkgs.oldpkgs.pywalfox-native ] ++ (import ./scripts { inherit pkgs; });

  xdg.configFile."matugen/config.toml".source = ./config.toml;
  xdg.configFile."matugen/templates".source = ./templates;

  xdg.configFile."matugen/post-hook-scripts/openrgb.sh" = {
    text = lib.mkDefault ''
      #!/usr/bin/env bash
      if [ -f "$HOME/.cache/matugen/openrgb" ]; then
        source "$HOME/.cache/matugen/openrgb"
        # inverse_primary because of hyprland style
        color=$(pastel darken 0.2 "$inverse_primary" 2>/dev/null | pastel format hex 2>/dev/null)
        script -q -c "openrgb -c ''${color#\#}" /dev/null
      fi
    '';
    executable = true;
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=matugen
  '';

  gtk = {
    enable = true;
    gtk3.extraCss = ''@import "colors.css";'';
    gtk4.extraCss = ''@import "colors.css";'';
  };

  qt = {
    enable = true;
    qt5ctSettings = {
      Appearance = {
        color_scheme_path = "${config.home.homeDirectory}/.config/qt5ct/colors/matugen.conf";
        custom_palette = true;
      };
    };
    
    qt6ctSettings = {
      Appearance = {
        color_scheme_path = "${config.home.homeDirectory}/.config/qt6ct/colors/matugen.conf";
        custom_palette = true;
      };
    };
  };

    # WARNING ! it's disable kde globals file for editing ! - If you need it, u can write script, or write it manually in ./config/kdeglobals
  xdg.configFile."kdeglobals".text = lib.mkAfter ''
    [UiSettings]
    ColorScheme=qt6ct
  '';
}