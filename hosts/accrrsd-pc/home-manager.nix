{ config, pkgs, inputs, outputs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      accrrsd = import ./users/accrrsd/user-config.nix;
    };
  };

  users.users.accrrsd = {
    isNormalUser = true;
    description = "accrrsd";
    extraGroups = [ "networkmanager" "wheel" "nixosgroup" ];
  };
}
