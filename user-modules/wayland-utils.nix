{ pkgs, ... }: {
  home.packages = with pkgs; [
    wl-clipboard
    wl-clip-persist
    cliphist
    brightnessctl
    wl-gammarelay-rs
    awww
    hyprshot
  ];
}
