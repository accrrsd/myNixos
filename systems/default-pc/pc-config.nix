{ lib, pkgs, ... }:

{
  imports = [
    ../default.nix
    ./users/users.nix
  ];

  # needed only in BIOS pc (not uefi) You should check your /etc/nixos/configuration.nix for current device.
  #boot.loader.grub.device = "/dev/sdb";
}
