{ config, lib, ... }:

let
  isUefi = lib.pathExists "/sys/firmware/efi/efivars";
in
{
  boot.loader.grub = {
    enable = true;
    useOSProber = true;
    efiSupport = isUefi;
    device = if isUefi then "nodev" else
      if config.boot.loader.grub.device != null && config.boot.loader.grub.device != ""
      then config.boot.loader.grub.device
      else throw "BIOS system detected, but boot.loader.grub.device is not set! Please specify the boot device (e.g., \"/dev/sda\").";
  };
}