
{ config, pkgs, ... }:

{
  users.users.accrrsd = {
    isNormalUser = true;
    description = "accrrsd";
    extraGroups = [ "networkmanager" "wheel" "nixosgroup" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
