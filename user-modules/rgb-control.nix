{ pkgs, ... }: {
  home.packages = with pkgs; [
    polychromatic
    openrgb-with-all-plugins
  ];
}
