{ config, pkgs, inputs, pkgsUnstable, outputs, ... }: {

  users.users.accrrsd = {
    isNormalUser = true;
    description = "accrrsd";
    # openrazer - for razer stuff and polyschromatic
    extraGroups = [ "networkmanager" "wheel" "nixos-editors" "docker" "openrazer" ];
    hashedPassword="$6$12cxH9oHnQ0ZAL3c$q/ODQaULn55xu.oxSfe26tIzd2oT3lX.jxATsrhdqBC6hqMyM5SuLjIo8GHQXw6Vbzp2HKpXACeZYSyekHf2Y0";
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs pkgsUnstable outputs; };
    users = {
      accrrsd = import ./accrrsd;
    };

    backupFileExtension = "hm-backup";
  };
}
