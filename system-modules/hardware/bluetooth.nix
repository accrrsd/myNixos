{ pkgs, ... }: {
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        #Enable = "Source,Sink,Media,Socket,HID";
        JustWorksRepairing = "always";
      };
    };
  };
  services.blueman.enable = true;
  #hardware.enableRedistributableFirmware = true;

  # For zmk keyboard
  boot.kernelModules = [ "hid_zmk" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="input", ATTRS{id/vendor}=="zmk", MODE="0666", GROUP="input"
  '';
}