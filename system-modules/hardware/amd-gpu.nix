{pkgs, ...}:
{
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr.icd
    ];
    enable32Bit = true;
    # For 32 bit applications 
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
}