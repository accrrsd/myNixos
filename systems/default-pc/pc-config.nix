{ lib, pkgs, ... }:

{
  imports = [
    ../default.nix
  ];

  users.users.test = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "nixos-editors" ];
    hashedPassword="$6$12cxH9oHnQ0ZAL3c$q/ODQaULn55xu.oxSfe26tIzd2oT3lX.jxATsrhdqBC6hqMyM5SuLjIo8GHQXw6Vbzp2HKpXACeZYSyekHf2Y0";
  };

  # needed only in BIOS pc (not uefi) You should check your /etc/nixos/configuration.nix for current device.
  boot.loader.grub.device = "/dev/sdb";
}
