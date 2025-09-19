{ config, pkgs, inputs, outputs, ... }: {

  # services.displayManager.autoLogin = {
  #   enable=true;
  #   user="accrrsd";
  # };

  users.users.accrrsd = {
    isNormalUser = true;
    description = "accrrsd";
    hashedPassword="$6$12cxH9oHnQ0ZAL3c$q/ODQaULn55xu.oxSfe26tIzd2oT3lX.jxATsrhdqBC6hqMyM5SuLjIo8GHQXw6Vbzp2HKpXACeZYSyekHf2Y0";
    extraGroups = [ "networkmanager" "wheel" "nixos-editors" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs ; };
    # import user as system-home manager, e.g sudo nixos-rebuild --flake
    users = {
      accrrsd = import ./accrrsd/user-config.nix;
    };

    # if home manager bugged - try to delete mimetypes from .config, if not worked - try to rename config to .config.backup
    backupFileExtension = "hm-backup";
  };
}