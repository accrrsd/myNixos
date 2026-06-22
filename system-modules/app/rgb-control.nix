{ pkgs, ... }: 
{
  services.udev.packages = [ 
    pkgs.openrgb-with-all-plugins 
    (pkgs.writeTextFile {
      name = "99-zz-lianli-razer-override";
      destination = "/etc/udev/rules.d/99-zz-lianli-razer-override.rules";
      text = ''
        # Prevent openrazer's razer_mount from hijacking the Lian Li case
        SUBSYSTEM=="hid", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="0f13", RUN="/bin/sh -c 'true'"
      '';
    })
  ];

  # 1. Force the kernel to use standard hid-generic and avoid special driver initialization
  boot.kernelParams = [ "usbhid.quirks=0x1532:0x0f13:0x00400000" ];
  
  boot.kernelModules = [ "i2c-dev" ];
  hardware.i2c.enable = true;
  
  services.hardware.openrgb = { 
    enable = true; 
    package = pkgs.openrgb-with-all-plugins;
  };
}