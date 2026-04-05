{ config, pkgs, lib, ... }:
{
  programs.kitty = {
    enable = true;
    # cant make it with mkDefault - something overrides it.
    extraConfig = ''
        background_opacity 0.5
        allow_remote_control yes
        confirm_os_window_close -1
        window_padding_width 4
        include ${config.home.homeDirectory}/.config/kitty/themes/Matugen.conf
        watch_for_conf_changes true
      '';
  };
}