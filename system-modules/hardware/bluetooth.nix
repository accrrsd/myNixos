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
  # if device is not connecterd, remove it (untrust etc) then connect -> trust -> pair
  services.blueman.enable = true;
  environment.systemPackages = with pkgs; [
    bluez-tools
    bluetuith # can transfer files via OBEX
  ];
}