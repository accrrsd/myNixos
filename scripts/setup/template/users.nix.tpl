{ config, pkgs, inputs, outputs, ... }: {
  users.users.{{USER_NAME}} = {
    isNormalUser = true;
    description = "{{USER_NAME}}";
    extraGroups = [ "networkmanager" "wheel" "nixos-editors" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      {{USER_NAME}} = import ./users/{{USER_NAME}}/user-config.nix;
    };
  };
}
