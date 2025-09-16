{ config, pkgs, inputs, outputs, ... }: {
  users.users.accrrsd = {
    isNormalUser = true;
    description = "accrrsd";
    extraGroups = [ "networkmanager" "wheel" "nixos-editors" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      accrrsd = import ./accrrsd/user-config.nix
    };

    # if home manager bugged - try to delete mimetypes from .config, if not worked - try to rename config to .config.backup
    backupFileExtension = "hm-backup";
  };
}