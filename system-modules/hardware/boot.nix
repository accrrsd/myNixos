{ config, lib, ... }:

let
  isUefi = lib.pathExists "/sys/firmware/efi/efivars";
in
{
  boot.loader.grub = {
    enable = true;
    # dual boot
    useOSProber = lib.mkDefault false;
    efiSupport = isUefi;
    device = lib.mkDefault (
      if isUefi then "nodev"
      else throw "BIOS system detected, but boot.loader.grub.device is not set! Please specify the boot device (e.g., \"/dev/sda\")."
    );
  };
}