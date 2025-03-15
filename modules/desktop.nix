
{ config, pkgs, ... }:

{
  services.xserver.enable = true;

  # Настройки видео-драйвера (если не NVIDIA):
  # services.xserver.videoDrivers = ["intel"];

  # KDE Plasma:
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Автоматический вход:
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "accrrsd";

  # Раскладка клавиатуры:
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  programs.firefox.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
}
