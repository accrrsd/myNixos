{ inputs, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    extraConfig = ''
      background_opacity 0.5
      confirm_os_window_close -1
      window_padding_width 4
    '';
  };
}