{ pkgs, ... }: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket,HID";
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;
  environment.systemPackages = with pkgs; [
    bluez-tools
    bluetuith # can transfer files via OBEX
  ];
}