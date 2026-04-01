{ pkgs, ... }:
{

  imports = [
    ./theme1
  ];

  home.packages = with pkgs; [
    rofi
  ];
}